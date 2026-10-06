# Notices

The MIT license applies to original scripts and documentation in this repository.
It does not relicense Amazon/MediaTek firmware or third-party components.

Karat installation uses that device's own aparam utility. The patch removes one
unused DT_NEEDED dependency on libmediaplayerservice.so, preserving command code
and reproducing the tested output hash. Neither the stock nor corrected binary
is committed or included in module ZIPs. The corrected overlay is generated
on the device during installation.

Amazon, Fire TV, Dolby and Magisk names identify compatibility; this project is
not affiliated with or endorsed by their owners.

Magisk module format: https://topjohnwu.github.io/Magisk/guides.html
