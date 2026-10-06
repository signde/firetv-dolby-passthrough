# Contributing

Keep changes scoped to a supported device and verified firmware. Include the
device codename, Fire OS build, player and passthrough mode, receiver, and the
expected versus observed behavior when reporting issues. Redact personal data
from logs; do not upload firmware dumps or media samples.

Run the build and relevant checks described in the README. Host checks do not
replace playback, seek/replay, boot and other-codec regression checks on hardware.
Preserve the published module ID. Increase versionCode for future releases.
Build ZIPs go in dist/ and are not committed. Publish installable ZIPs as release
assets, not GitHub's automatically generated source archives.
