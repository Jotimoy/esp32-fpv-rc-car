#include <Arduino.h>
#include <ArduinoJson.h>
#include <WebSocketsServer.h>
#include <WiFi.h>

#if __has_include("config.h")
#include "config.h"
#else
#include "config.example.h"
#endif

namespace {
constexpr uint16_t kWebSocketPort = 81;
constexpr uint32_t kCommandTimeoutMs = 750;
constexpr uint8_t kDefaultSpeed = 180;

// Left BTS7960
constexpr uint8_t kLeftRpwmPin = 25;
constexpr uint8_t kLeftLpwmPin = 26;
constexpr uint8_t kLeftRenPin = 27;
constexpr uint8_t kLeftLenPin = 14;

// Right BTS7960
constexpr uint8_t kRightRpwmPin = 32;
constexpr uint8_t kRightLpwmPin = 33;
constexpr uint8_t kRightRenPin = 18;
constexpr uint8_t kRightLenPin = 19;

constexpr uint8_t kLeftRpwmChannel = 0;
constexpr uint8_t kLeftLpwmChannel = 1;
constexpr uint8_t kRightRpwmChannel = 2;
constexpr uint8_t kRightLpwmChannel = 3;
constexpr uint16_t kPwmFrequency = 20000;
constexpr uint8_t kPwmResolution = 8;

WebSocketsServer webSocket(kWebSocketPort);
uint32_t lastCommandAt = 0;
bool motorsRunning = false;

void setMotor(uint8_t forwardChannel, uint8_t reverseChannel, int16_t speed) {
  const uint8_t pwm = static_cast<uint8_t>(constrain(abs(speed), 0, 255));
  if (speed > 0) {
    ledcWrite(forwardChannel, pwm);
    ledcWrite(reverseChannel, 0);
  } else if (speed < 0) {
    ledcWrite(forwardChannel, 0);
    ledcWrite(reverseChannel, pwm);
  } else {
    ledcWrite(forwardChannel, 0);
    ledcWrite(reverseChannel, 0);
  }
}

void stopMotors() {
  setMotor(kLeftRpwmChannel, kLeftLpwmChannel, 0);
  setMotor(kRightRpwmChannel, kRightLpwmChannel, 0);
  motorsRunning = false;
}

bool drive(const String &action, uint8_t speed) {
  if (action == "forward") {
    setMotor(kLeftRpwmChannel, kLeftLpwmChannel, speed);
    setMotor(kRightRpwmChannel, kRightLpwmChannel, speed);
  } else if (action == "backward") {
    setMotor(kLeftRpwmChannel, kLeftLpwmChannel, -speed);
    setMotor(kRightRpwmChannel, kRightLpwmChannel, -speed);
  } else if (action == "left") {
    setMotor(kLeftRpwmChannel, kLeftLpwmChannel, -speed);
    setMotor(kRightRpwmChannel, kRightLpwmChannel, speed);
  } else if (action == "right") {
    setMotor(kLeftRpwmChannel, kLeftLpwmChannel, speed);
    setMotor(kRightRpwmChannel, kRightLpwmChannel, -speed);
  } else if (action == "stop") {
    stopMotors();
    return true;
  } else {
    return false;
  }

  motorsRunning = true;
  return true;
}

void sendResponse(uint8_t clientId, const char *type, uint32_t sequence,
                  const char *message) {
  JsonDocument response;
  response["v"] = 1;
  response["type"] = type;
  response["seq"] = sequence;
  response["message"] = message;
  response["uptime_ms"] = millis();
  String payload;
  serializeJson(response, payload);
  webSocket.sendTXT(clientId, payload);
}

void handleText(uint8_t clientId, uint8_t *payload, size_t length) {
  JsonDocument command;
  const DeserializationError error = deserializeJson(command, payload, length);
  if (error) {
    sendResponse(clientId, "error", 0, "invalid_json");
    return;
  }

  const uint32_t sequence = command["seq"] | 0;
  const char *type = command["type"] | "";
  const char *action = command["action"] | "";
  const int requestedSpeed = command["speed"] | kDefaultSpeed;
  const uint8_t speed =
      static_cast<uint8_t>(constrain(requestedSpeed, 0, 255));

  if (strcmp(type, "drive") != 0 || !drive(String(action), speed)) {
    sendResponse(clientId, "error", sequence, "invalid_command");
    return;
  }

  lastCommandAt = millis();
  sendResponse(clientId, "ack", sequence, action);
}

void webSocketEvent(uint8_t clientId, WStype_t type, uint8_t *payload,
                    size_t length) {
  switch (type) {
    case WStype_CONNECTED:
      sendResponse(clientId, "status", 0, "connected");
      break;
    case WStype_TEXT:
      handleText(clientId, payload, length);
      break;
    case WStype_DISCONNECTED:
      stopMotors();
      break;
    default:
      break;
  }
}

void configurePwm() {
  ledcSetup(kLeftRpwmChannel, kPwmFrequency, kPwmResolution);
  ledcSetup(kLeftLpwmChannel, kPwmFrequency, kPwmResolution);
  ledcSetup(kRightRpwmChannel, kPwmFrequency, kPwmResolution);
  ledcSetup(kRightLpwmChannel, kPwmFrequency, kPwmResolution);
  ledcAttachPin(kLeftRpwmPin, kLeftRpwmChannel);
  ledcAttachPin(kLeftLpwmPin, kLeftLpwmChannel);
  ledcAttachPin(kRightRpwmPin, kRightRpwmChannel);
  ledcAttachPin(kRightLpwmPin, kRightLpwmChannel);

  pinMode(kLeftRenPin, OUTPUT);
  pinMode(kLeftLenPin, OUTPUT);
  pinMode(kRightRenPin, OUTPUT);
  pinMode(kRightLenPin, OUTPUT);
  digitalWrite(kLeftRenPin, HIGH);
  digitalWrite(kLeftLenPin, HIGH);
  digitalWrite(kRightRenPin, HIGH);
  digitalWrite(kRightLenPin, HIGH);
  stopMotors();
}

void connectNetwork() {
  if (strlen(WIFI_SSID) > 0) {
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.printf("Connecting to %s", WIFI_SSID);
    const uint32_t startedAt = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - startedAt < 15000) {
      delay(250);
      Serial.print(".");
    }
    if (WiFi.status() == WL_CONNECTED) {
      Serial.printf("\nWebSocket: ws://%s:%u/\n",
                    WiFi.localIP().toString().c_str(), kWebSocketPort);
      return;
    }
    Serial.println("\nWi-Fi connection failed; starting access point.");
  }

  WiFi.mode(WIFI_AP);
  WiFi.softAP(AP_SSID, AP_PASSWORD);
  Serial.printf("Join AP '%s', then connect to ws://%s:%u/\n", AP_SSID,
                WiFi.softAPIP().toString().c_str(), kWebSocketPort);
}
}  // namespace

void setup() {
  Serial.begin(115200);
  configurePwm();
  connectNetwork();
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
}

void loop() {
  webSocket.loop();
  if (motorsRunning && millis() - lastCommandAt > kCommandTimeoutMs) {
    stopMotors();
  }
}
