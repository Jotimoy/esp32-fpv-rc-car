# Architecture

Staged Flutter and ESP32 RC car project with a WebSocket control protocol.

```mermaid
flowchart LR
  N0["Flutter controller"]
  N1["WiFi WebSocket"]
  N2["ESP32"]
  N3["BTS7960 drivers"]
  N0 --> N1
  N1 --> N2
  N2 --> N3
```

## Boundaries

Phase 1 implements local control. The camera/relay app and Internet/WebRTC signaling are later-phase scaffolds, not a completed remote FPV system.

## Layout

- `CHANGELOG.md`
- `README.md`
- `apps` — directory
- `docs` — directory
- `firmware` — directory
- `protocol` — directory
- `server` — directory
