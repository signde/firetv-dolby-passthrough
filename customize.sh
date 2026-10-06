#!/system/bin/sh

[ "$BOOTMODE" = true ] || abort "Install from Magisk while Fire OS is running."
[ -x /system/bin/aparam ] || abort "Required audio parameter utility is missing."
DEVICE=$(getprop ro.product.device)
case "$DEVICE" in
    gazelle)
        ui_print "Fire TV Cube 3: using the stock aparam."
        ;;
    karat)
        mkdir -p "$MODPATH/system/bin"
        sh "$MODPATH/scripts/patch_karat_aparam.sh" /system/bin/aparam "$MODPATH/system/bin/aparam" ||
            abort "Unsupported Karat utility or overlay patch failed."
        set_perm "$MODPATH/system/bin/aparam" 0 2000 0755
        ui_print "Fire TV Stick 4K Max 2: installing corrected aparam overlay."
        ;;
    *) abort "Supported devices: gazelle and karat only." ;;
esac
set_perm "$MODPATH/service.sh" 0 0 0755
ui_print "Reboot to activate. HDMI BYPASS is applied about 60 seconds after boot completion."
ui_print "Reapplies BYPASS on resume events, with bounded follow-up checks and no idle polling."
ui_print "Disable/remove and reboot to restore stock behavior."
