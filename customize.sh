#!/system/bin/sh

[ "$BOOTMODE" = true ] || abort "Install from Magisk while Fire OS is running."
[ -x /system/bin/aparam ] || abort "Required audio parameter utility is missing."
DEVICE=$(getprop ro.product.device)
case "$DEVICE" in
    gazelle)
        ui_print "Fire TV Cube 3: using the stock aparam."
        ;;
    karat)
        ORIGINAL=1ec08b6cdf633a683ace6123991b2b5b440f155804cd24b8081de287ad7e41b7
        CORRECTED=690cfd8c33e3c02d68c7e0d1c51415530907bcf41f1cf8784186ba17c897e4f2
        ACTUAL=$(sha256sum /system/bin/aparam)
        ACTUAL=${ACTUAL%% *}
        case "$ACTUAL" in
            "$ORIGINAL"|"$CORRECTED") ;;
            *) abort "Unsupported Karat aparam build. No patch installed." ;;
        esac
        PAYLOAD=$(sha256sum "$MODPATH/payload/aparam-karat")
        PAYLOAD=${PAYLOAD%% *}
        [ "$PAYLOAD" = "$CORRECTED" ] || abort "Karat payload checksum mismatch."
        mkdir -p "$MODPATH/system/bin"
        cp "$MODPATH/payload/aparam-karat" "$MODPATH/system/bin/aparam"
        set_perm "$MODPATH/system/bin/aparam" 0 2000 0755
        ui_print "Fire TV Stick 4K Max 2: installing corrected aparam overlay."
        ;;
    *) abort "Supported devices: gazelle and karat only." ;;
esac
rm -rf "$MODPATH/payload"
set_perm "$MODPATH/service.sh" 0 0 0755
ui_print "Reboot to activate. HDMI BYPASS is applied about 60 seconds after boot completion."
ui_print "Reapplies BYPASS on resume events, with bounded follow-up checks and no idle polling."
ui_print "Disable/remove and reboot to restore stock behavior."
