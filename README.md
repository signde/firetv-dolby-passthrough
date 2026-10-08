# Fire TV Dolby Digital & DD+ Passthrough

Magisk module that enables DD and DD+ passthrough, including DD+ Atmos, by
maintaining Fire OS HDMI bypass mode at boot, after sleep/wake and after service
restarts. **Version 0.3.2. Root and Magisk required.**

## Tested devices

| Device | Playback-tested firmware | Recovery checks |
| --- | --- | --- |
| Fire TV Cube 3 (`gazelle`) | 7.7.0.2 PS7702/4965; 7.7.1.4 PS7714/5506; 7.7.1.7 PS7717/5741 | Boot/wake; restart recovery on PS7714 and PS7717 |
| Fire TV Stick 4K Max 2 (`karat`) | 8.1.8.2 RS8182.3811N | v0.3.2 boot/wake verified; independent restart recovery unverified |

Gazelle installation checks the device and audio utility. Karat also requires a
matching utility hash and rejects unknown versions.

## Installation

1. Install the [v0.3.2 module ZIP](https://github.com/signde/firetv-dolby-passthrough/releases/download/v0.3.2/firetv-dolby-passthrough-v0.3.2.zip)
   through Magisk in Fire OS, then reboot.
2. Select **Best Available** in Fire OS and enable passthrough in your player.
3. Allow about one minute after boot for bypass to apply.

GitHub's automatic source ZIP is not an installable module. Your player and
receiver must support passthrough.

To uninstall, disable/remove the module in Magisk and reboot. Disable it before
updating firmware, then check compatibility before enabling it again.

## Checking the audio mode

From a root shell:

```sh
aparam get 0 hdmi_format
# Expected: hdmi_format=6
```

To apply bypass immediately:

```sh
aparam set 0 hdmi_format=6
```

The default is mode `5`. Disable the module before intentionally choosing another
mode, otherwise a later boot/wake/restart event may restore bypass.

For troubleshooting:

```sh
tail -40 /data/adb/modules/gazelle_ddplus_bypass/boot.log
```

The module reacts to boot, screen-on and framework/audio restart events, with
brief follow-up checks. It does not poll HDMI while idle or hold a wake lock.
Resets outside those events may require manually reapplying bypass.

## Karat audio utility fix

Karat's stock `aparam` can abort after successfully applying a command. This
module generates a corrected copy from the device's own utility and applies it
through a Magisk overlay. The original system file is untouched; removing the
module and rebooting removes the overlay. No firmware binaries are bundled.

## Related DTS module

[Fire TV DTS-HD MA & DTS:X Passthrough](https://github.com/signde/firetv-dtshd-passthrough)
provides the separate DTS packing fix and requires this module to maintain HDMI
bypass. The Dolby module works independently.

## License

Project code is MIT licensed. See [NOTICE.md](NOTICE.md) for firmware provenance
and exclusions, and [CHANGELOG.md](CHANGELOG.md) for version history.
