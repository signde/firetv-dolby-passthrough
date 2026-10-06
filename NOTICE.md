# Notices

The MIT license applies to original scripts and documentation in this repository.
It does not relicense Amazon/MediaTek firmware or third-party components.

The Karat build requires the user's stock aparam utility. The patch removes one
unused DT_NEEDED dependency on libmediaplayerservice.so, preserving command code
and reproducing the tested output hash. Neither the stock nor corrected binary
is committed. Locally generated module ZIPs include the corrected binary.

Amazon, Fire TV, Dolby and Magisk names identify compatibility; this project is
not affiliated with or endorsed by their owners.

Magisk module format: https://topjohnwu.github.io/Magisk/guides.html
