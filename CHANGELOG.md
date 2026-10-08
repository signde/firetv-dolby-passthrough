# Changelog

## 0.3.2

- Restore bypass after Android framework and audio-server restarts.
- Test restart recovery on Cube 3 PS7714 and PS7717, and boot/wake handling on
  Karat RS8182.3811N.

## 0.3.1

- Generate Karat's corrected audio utility on-device instead of bundling a
  firmware binary. Support upgrades from an already-corrected utility.

## 0.3.0

- Support Cube 3 and Stick 4K Max 2 in one module.
- Restore bypass after boot and sleep/wake without periodic idle polling.
- Fix Karat's audio-utility exit crash.
