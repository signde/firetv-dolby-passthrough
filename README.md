# Fire TV Dolby Digital & DD+ Passthrough

Magisk module that maintains Fire OS HDMI bypass (`hdmi_format=6`) at boot
and after sleep/wake, enabling DD and DD+ passthrough including DD+ Atmos.

| Device | Playback-tested build |
| --- | --- |
| Fire TV Cube 3 (`gazelle`) | Fire OS 7.7.0.2, PS7702/4965 |
| Fire TV Stick 4K Max 2 (`karat`) | Fire OS 8.1.8.2, RS8182.3811N |

Version **0.3.0**. Root and Magisk are required. Karat installation accepts only
the exact utility hashes documented in [Karat utility details](#karat-utility). Gazelle's
installer checks the device and utility presence, not the entire firmware build;
other builds have not been validated here.

## Installation and use

Install a built module ZIP from Magisk, then reboot. Select **Best Available**
in Fire OS and enable passthrough in your player. Allow about one minute after
boot for bypass to apply. The installer does not support recovery installation.
GitHub's automatic source ZIP is not an installable module ZIP.

Verify from a root shell:

```sh
aparam get 0 hdmi_format
# Expected: hdmi_format=6
```

Boot and resume trigger bounded follow-up checks. There are no periodic HDMI
queries while idle. An HDMI reset without a screen-on event is not covered.
Manual output-mode changes may be overridden on boot/resume. Disable/remove the
module in Magisk and reboot to undo it. Revalidate compatibility after firmware
updates. Disable the module before upgrading firmware.

## Boot, resume and logs

After `sys.boot_completed=1`, the service waits 60 seconds for Fire OS audio
preferences, applies bypass, and checks again at +5 and +20 seconds. It then
blocks on Android's `power_screen_state` event stream. Screen-on/resume triggers
checks at 0, 5 and 20 seconds, including exit from dreams when Fire OS emits that
event. There is no wake lock. Each check verifies the live audio-service readback.

Audio-service failures are retried within those bounded checks, then on the next
resume. A failed event stream reconnects after 30 seconds. Disabling/removing the
module stops writes at the next event/check; reboot ends the listener and removes
the Karat overlay. App and receiver passthrough support are still required.

Logs are under `/data/adb/modules/gazelle_ddplus_bypass/`:

- `boot.log`: current session, rotating at approximately 64 KiB to `boot.log.1`.
- `previous-boot.log`: previous run.

For immediate manual bypass, run `aparam set 0 hdmi_format=6` from a root shell.
The default mode is `aparam set 0 hdmi_format=5`. Disable the module before
intentionally selecting another mode.

## Karat utility

Gazelle uses its original `/system/bin/aparam`. Karat receives a Magisk overlay
at that path with the unused direct `libmediaplayerservice.so` dependency removed.
This prevents the observed exit-time `ALooperRoster` mutex destruction crash
without changing the utility's command code. The system partition is not modified;
the module includes no SELinux or ADB changes.

The installer accepts only the known stock binary or its exact corrected version.
The service also verifies the corrected utility before using it.

| Karat utility | SHA256 |
| --- | --- |
| Stock | `1ec08b6cdf633a683ace6123991b2b5b440f155804cd24b8081de287ad7e41b7` |
| Corrected | `690cfd8c33e3c02d68c7e0d1c51415530907bcf41f1cf8784186ba17c897e4f2` |

After the startup delay, querying the mode should return `hdmi_format=6` without
the Karat abort. Disable/remove and reboot to remove the overlay and boot handling.

## Build from source

Requires Python 3.9+ and a POSIX shell. No Python packages are needed. Supply a
local copy of the **stock** Karat `/system/bin/aparam` with the documented hash.
If the module is already installed, the visible utility may be the patched overlay;
use your original backup or stock firmware copy. This binary is not in the repo.

```sh
python3 build.py --karat-aparam /path/to/stock/karat/aparam
```

The builder removes the unused direct `libmediaplayerservice.so` dependency,
verifies the exact tested output hash, and writes the ZIP and checksum to `dist/`.
It preserves the tested v0.3.0 runtime scripts. The generated ZIP includes the
corrected firmware utility; this repository contains only the patching source.
Generating the overlay at installation time is a separate future change.

## Related module

[Fire TV DTS-HD MA & DTS:X Passthrough](https://github.com/signde/firetv-dtshd-passthrough)
adds the separate, firmware-specific DTS packing fix. Dolby works independently;
the current DTS version requires this module to maintain bypass across sleep/wake.
The historical module ID `gazelle_ddplus_bypass` is retained for compatible upgrades.

## License and status

Original project code is MIT licensed. See [NOTICE.md](NOTICE.md) for firmware
provenance and exclusions. No update feed or automated publishing is configured.
Release notes are in [CHANGELOG.md](CHANGELOG.md).
