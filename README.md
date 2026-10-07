# Fire TV Dolby Digital & DD+ Passthrough

Magisk module that maintains Fire OS HDMI bypass (`hdmi_format=6`) at boot
and after sleep/wake or service restarts, enabling DD and DD+ passthrough including DD+ Atmos.

| Device | Playback-tested build |
| --- | --- |
| Fire TV Cube 3 (`gazelle`) | Fire OS 7.7.0.2, PS7702/4965; 7.7.1.4, PS7714/5506; 7.7.1.7, PS7717/5741 |
| Fire TV Stick 4K Max 2 (`karat`) | Fire OS 8.1.8.2, RS8182.3811N |

Version **0.3.2**. Root and Magisk are required. Karat installation accepts only
the exact utility hashes documented in [Karat utility details](#karat-utility). Gazelle's
installer checks the device and utility presence, not the entire firmware build;
other builds have not been validated here. The new restart recovery passed controlled framework/audio restarts on Gazelle
PS7714.5506N. PS7717.5741N also passed framework-restart and sleep/wake
recovery with receiver-confirmed playback, and the user confirmed its manual
audio/video check passed. The Karat playback result predates v0.3.2; the new
restart recovery has not been hardware-retested there.

## Installation and use

Install the [v0.3.2 module ZIP](https://github.com/signde/firetv-dolby-passthrough/releases/download/v0.3.2/firetv-dolby-passthrough-v0.3.2.zip)
from Magisk, then reboot. Select **Best Available**
in Fire OS and enable passthrough in your player. Allow about one minute after
boot for bypass to apply. The installer does not support recovery installation.
GitHub's automatic source ZIP is not an installable module ZIP.

Verify from a root shell:

```sh
aparam get 0 hdmi_format
# Expected: hdmi_format=6
```

Boot, resume and service restart events trigger bounded follow-up checks. There
are no periodic HDMI queries while idle. Resets without a watched event, or after
its bounded follow-up window, are not covered. Manual output-mode changes may
be overridden following these events. Disable/remove the
module in Magisk and reboot to undo it. Revalidate compatibility after firmware
updates. Disable the module before upgrading firmware.

## Boot, resume and logs

After `sys.boot_completed=1`, the service waits 60 seconds for Fire OS audio
preferences, applies bypass, and checks again at +5 and +20 seconds. It then
blocks on filtered Android events and main logs. `power_screen_state` screen-on
events trigger checks at 0, 5 and 20 seconds. `boot_progress_enable_screen` after
framework startup and `AudioService: Audioserver started.` after audio-server
recovery trigger checks at 0, 5, 20 and 60 seconds. The later check covers delayed
saved-preference resets. There is no wake lock. Each check verifies live readback.

Audio-service failures are retried within those bounded checks, then on the next
watched event. A failed event stream reconnects after 30 seconds. Disabling/removing the
module stops writes at the next event/check; reboot ends the listener and removes
the Karat overlay. App and receiver passthrough support are still required.

Logs are under `/data/adb/modules/gazelle_ddplus_bypass/`:

- `boot.log`: current session, rotating at approximately 64 KiB to `boot.log.1`.
- `previous-boot.log`: previous run.

For immediate manual bypass, run `aparam set 0 hdmi_format=6` from a root shell.
The default mode is `aparam set 0 hdmi_format=5`. Disable the module before
intentionally selecting another mode.

## Movistar Plus+ community result

[CMBoii's follow-up on Cube 3 PS7704](https://xdaforums.com/t/mod-magisk-root-fireos-7-8-dolby-dd-dd-and-dts-hd-ma-dts-x-passthrough-modules.4804107/post-90767387)
resolved the earlier stereo-output report. His reported captures show movie
playback supplying E-AC3, six channels, in both modes; in bypass mode the Denon
receives DD+. The tested live channels instead supplied AAC stereo in both modes,
with AVR upmixing explaining the earlier surround impression. This is community
verification of those streams, not a local reproduction or a guarantee for all
Movistar content. No module change was needed for the reported issue.

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

Requires Python 3.9+ and a POSIX shell. No firmware binaries or Python packages
are needed to build the module.

```sh
python3 tests/test_recovery.py
python3 build.py
```

The ZIP contains source scripts only. During installation on Karat, the installer
copies the device's existing `/system/bin/aparam`, removes the unused direct
`libmediaplayerservice.so` dependency, verifies the exact tested output hash, and
places the result in the Magisk overlay. It accepts either the supported stock
utility or an already-corrected overlay when upgrading. The original file is never
modified. Gazelle continues to use its own stock utility.

For developers, `scripts/patch_karat_aparam.py` is an independent ELF-aware reference
implementation. `tests/test_patch.py --stock /path/to/stock/aparam` compares the shell
patch with that implementation, checks upgrades from the corrected binary, and
verifies rejection of unsupported input. Test binaries stay outside the repo.

Release checks passed for stock-to-corrected patching, upgrades from the corrected
utility, unchanged inputs, unsupported-input rejection and temporary-file cleanup.
The exact installer was also rehearsed in isolated directories on Karat and Gazelle
using Magisk BusyBox. Karat produced the verified hash and queried the audio mode
without the previous mutex abort. These checks did not replace the live modules.

## Related module

[Fire TV DTS-HD MA & DTS:X Passthrough](https://github.com/signde/firetv-dtshd-passthrough)
adds the separate, firmware-specific DTS packing fix. Dolby works independently;
the current DTS version requires this module to maintain bypass across sleep/wake.
The historical module ID `gazelle_ddplus_bypass` is retained for compatible upgrades.

## License and status

Original project code is MIT licensed. See [NOTICE.md](NOTICE.md) for firmware
provenance and exclusions. No update feed or automated publishing is configured.
Release notes are in [CHANGELOG.md](CHANGELOG.md).
