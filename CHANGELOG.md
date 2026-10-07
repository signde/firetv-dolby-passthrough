# Changelog

## 0.3.2

- Recover bypass after Android framework and audio-server restarts.
- Check immediately and at +5, +20 and +60 seconds following a restart to catch
  delayed saved-preference resets. Boot and resume retain their existing timing.
- Watch filtered startup and power events without periodic HDMI queries.
- Verify restart recovery on Cube 3 PS7714.5506N and PS7717.5741N; the user
  confirmed final PS7717 audio/video testing passed. Karat restart recovery
  remains untested on hardware.

## 0.3.1

- Generate the verified Karat overlay from the device's own utility at installation.
- Remove the firmware binary from the module ZIP and build inputs.
- Preserve the v0.3.0 boot/resume behavior and corrected utility bytes.
- Accept the supported stock utility and already-corrected overlay for upgrades.

## 0.3.0

- Maintain HDMI bypass after boot and screen-on/resume events.
- Use bounded follow-up checks instead of periodic idle HDMI queries.
- Support Gazelle and Karat with a verified Karat utility overlay that corrects
  the observed exit-time mutex abort.
- Keep the legacy module ID for upgrades from the earlier Cube-only module.

## Source repository preparation

- Add a repeatable build and source for reproducing the Karat dependency patch.
- Preserve the hardware-tested runtime and document compatibility and rollback.
- No new device deployment or runtime behavior change.
