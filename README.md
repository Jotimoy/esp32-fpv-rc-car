# ESP32 FPV RC Car

Staged Flutter and ESP32 RC car project with a WebSocket control protocol.

**Platform:** ESP32

**Status:** Prototype / learning collection

**Entry point:** [firmware/esp32_fpv_car/src/main.cpp](firmware/esp32_fpv_car/src/main.cpp)

## What it does

- Flutter controller app
- PlatformIO ESP32 firmware
- Versioned control protocol
- FastAPI signaling scaffold

## Start here

Follow the commands in [Setup](docs/SETUP.md).

## Repository guide

| Document | Purpose |
|---|---|
| [Setup](docs/SETUP.md) | Installation, configuration and first run |
| [Architecture](docs/ARCHITECTURE.md) | Components and data flow |
| [Source inventory](docs/SOURCES.md) | Files, variants and retained attribution |
| [Validation](docs/VALIDATION.md) | Checks performed and remaining tests |

## Scope and limitations

Phase 1 implements local control. The camera/relay app and Internet/WebRTC signaling are later-phase scaffolds, not a completed remote FPV system.

Hardware behavior is not verified by a successful source upload. See the validation record before using a prototype.

## Source and attribution

Organized from existing project files. Original contributor and tutorial comments are retained where present. No blanket license is assigned to material whose original license was not supplied. See [source notes](docs/SOURCES.md).
