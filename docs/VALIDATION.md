# Validation

Recorded on 2026-09-11. Checks are limited to the scope stated here; archived variants are not assumed to work because the primary entry point passes.

## Source/package checks

- Python files parsed: **2**.
- Local Markdown links checked: **95**.
- Credential placeholder scan and exclusion of local runtime/dependency files: performed.

## Executed Flutter checks

- Controller app `flutter analyze`: passed.
- Controller app `flutter test`: passed (one widget test).
- Car app `flutter analyze`: passed.
- Car app `flutter test`: passed (one widget test).

Python signaling source syntax was checked. PlatformIO firmware compilation and physical controller-to-car tests have not been run in this packaging pass.

## Hardware validation still required

- Confirm the selected board, wiring, supply voltage and default output states.
- Verify sensor detection and calibrate readings against known references.
- Test disconnection/reconnection behavior and actuator controls on the actual hardware.
