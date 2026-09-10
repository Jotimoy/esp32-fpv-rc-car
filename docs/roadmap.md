# Development Roadmap

## Phase 1: Local buttons

- Direct controller app to ESP32 WebSocket
- Forward, backward, pivot left, pivot right, stop
- Command acknowledgements, disconnect stop, 750 ms watchdog
- Bench testing and wiring validation

Exit criterion: all directions work reliably for 15 minutes with wheels lifted,
and every connection loss stops the motors.

## Phase 2: Joystick and PWM

- Replace buttons with normalized `throttle` and `steering`
- Differential-drive mixing and dead zone
- Rate limiting, acceleration ramp, battery telemetry

## Phase 3: Car phone camera

- Camera preview and permissions in `car_app`
- Keep-screen-awake and thermal/battery monitoring
- Local controller-to-car-app test mode

## Phase 4: FastAPI signaling

- Authenticated rooms, offer/answer/ICE relay
- Deployment, TLS, structured logs, health checks

## Phase 5: WebRTC video

- Car-to-controller video track
- Adaptive bitrate, reconnect flow, TURN fallback

## Phase 6: DataChannel control

- Controller-to-car DataChannel
- Car app validates and forwards commands to ESP32
- End-to-end latency metrics and remote emergency stop

## Phase 7: GPS tracking

- Car phone location telemetry
- Map UI, route trail, stale-location warnings
