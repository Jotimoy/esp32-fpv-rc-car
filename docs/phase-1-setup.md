# Phase 1 Setup

## Safety first

- Test with wheels lifted off the ground.
- Add a fuse between the 3S battery and motor power rail.
- Never power motors from the ESP32 or buck converter's logic output.
- Connect ESP32 ground, both BTS7960 grounds, and battery negative together.
- Set the buck converter output to 5 V before connecting the ESP32.
- A 3S lithium-ion pack needs a suitable BMS and charger.

## Required motor drivers

Use **two BTS7960 modules**, one for each independently controlled side. Wire
two same-side motors in parallel only if their combined stall current remains
within the driver, battery, wiring, and connector ratings.

## ESP32 to BTS7960 wiring

| Function | ESP32 pin |
|---|---:|
| Left RPWM | GPIO 25 |
| Left LPWM | GPIO 26 |
| Left R_EN | GPIO 27 |
| Left L_EN | GPIO 14 |
| Right RPWM | GPIO 32 |
| Right LPWM | GPIO 33 |
| Right R_EN | GPIO 18 |
| Right L_EN | GPIO 19 |

Connect each driver's `VCC` to ESP32 `5V/VIN` (or the appropriate logic supply
for your module) and `GND` to common ground. Connect battery motor power to
`B+`/`B-`, and the motor side to `M+`/`M-`.

## Flash firmware

Install PlatformIO, then:

```bash
cd firmware/esp32_fpv_car
pio run --target upload
pio device monitor
```

The default configuration starts access point:

```text
SSID: FPV-RC-CAR
Password: fpvrc123
WebSocket: ws://192.168.4.1:81/
```

To use an existing router, copy `include/config.example.h` to
`include/config.h` and fill in `WIFI_SSID` and `WIFI_PASSWORD`.

## Run controller

Join the ESP32 Wi-Fi network from the Android phone, then:

```bash
cd apps/controller_app
flutter pub get
flutter run
```

Tap **Connect**, then press and hold a direction. Releasing it sends `stop`.
The ESP32 also stops automatically after 750 ms without a command.

## Bring-up sequence

1. Flash ESP32 with motor power disconnected.
2. Confirm the serial monitor prints the WebSocket URL.
3. Connect the app and verify acknowledgements while motor power is off.
4. Lift wheels, connect motor power, and briefly test each direction.
5. If one side runs backward, swap that side's motor leads.
