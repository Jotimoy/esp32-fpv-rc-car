# ESP32 FPV RC Car — Setup

## Project stages

The original [Phase 1 setup](phase-1-setup.md), [architecture](ARCHITECTURE.md), [roadmap](roadmap.md) and [control protocol](../protocol/control-v1.md) document the staged implementation.

## Firmware

Install PlatformIO, then:

```sh
cd firmware/esp32_fpv_car
cp include/config.example.h include/config.h
# Edit include/config.h for your hardware and local network.
pio run
# After selecting the connected device:
pio run --target upload
```

The platform and dependency versions are recorded in `platformio.ini`. Use the local Wi-Fi/WebSocket setup described in the Phase 1 guide.

## Flutter apps

With Flutter and the platform SDK installed:

```sh
cd apps/controller_app
flutter pub get
flutter analyze
flutter run
```

The `apps/car_app` folder follows the same commands but is a later-phase scaffold. Do not infer Internet video support from its existence.

## Signaling scaffold

```sh
cd server/signaling
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 127.0.0.1 --port 8000
```

The current service is a minimal health endpoint; WebRTC room signaling is planned work.
