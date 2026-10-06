#!/system/bin/sh

# Magisk runs this in its BusyBox ash standalone environment.
MODDIR=${0%/*}
umask 077
# Kernel-backed lock is released even if the process is killed.
exec 9> /dev/gazelle_ddplus_bypass.lock
flock -n 9 || exit 0
[ ! -f "$MODDIR/boot.log" ] || mv -f "$MODDIR/boot.log" "$MODDIR/previous-boot.log"
# Open the log per message so rotation also bounds a long-running session.
: > "$MODDIR/boot.log"
log() {
    size=$(wc -c < "$MODDIR/boot.log" 2>/dev/null)
    if [ "${size:-0}" -ge 65536 ]; then
        mv -f "$MODDIR/boot.log" "$MODDIR/boot.log.1"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] $*" >> "$MODDIR/boot.log"
}
enabled() { [ ! -e "$MODDIR/disable" ] && [ ! -e "$MODDIR/remove" ]; }
read_mode() {
    timeout 5 /system/bin/aparam get 0 hdmi_format 2>/dev/null |
        tr -d '\r' | sed -n 's/^hdmi_format=\([0-9][0-9]*\)$/\1/p'
}

DEVICE=$(/system/bin/getprop ro.product.device)
log "Startup v0.3.0: $DEVICE $(/system/bin/getprop ro.build.display.id)"
case "$DEVICE" in
    gazelle) ;;
    karat)
        expected=690cfd8c33e3c02d68c7e0d1c51415530907bcf41f1cf8784186ba17c897e4f2
        actual=$(sha256sum /system/bin/aparam)
        actual=${actual%% *}
        [ "$actual" = "$expected" ] || {
            log "Corrected Karat aparam overlay is unavailable; exiting."
            exit 1
        }
        ;;
    *) log "Unsupported device; exiting."; exit 1 ;;
esac
[ -x /system/bin/aparam ] || { log "aparam is unavailable."; exit 1; }

# This late-start service does not block Android boot. Give boot five minutes.
attempt=0
while [ "$(/system/bin/getprop sys.boot_completed)" != 1 ]; do
    enabled || exit 0
    attempt=$((attempt + 1))
    [ "$attempt" -le 150 ] || { log "Boot completion timed out."; exit 1; }
    sleep 2
done

# Fire OS applies saved audio preferences after sys.boot_completed becomes 1.
# On PS7702 this reset occurred after v0.1.0 had already exited successfully.
log "Boot complete; allowing 60 seconds for saved audio preferences."
settle=0
while [ "$settle" -lt 12 ]; do
    enabled || exit 0
    sleep 5
    settle=$((settle + 1))
done
# Only bounded checks after boot or a resume event. Nothing queries the HAL
# while the event reader is idle, and neither the reader nor sleeps hold a wake lock.
wait_enabled() {
    remaining=$1
    while [ "$remaining" -gt 0 ]; do
        enabled || return 1
        if [ "$remaining" -gt 5 ]; then chunk=5; else chunk=$remaining; fi
        sleep "$chunk"
        remaining=$((remaining - chunk))
    done
    enabled
}

reconcile() {
    reason=$1
    log "$reason: checking BYPASS now, then at +5s and +20s."
    # No infinite retries if the HAL is unavailable or rejects the setting.
    for delay in 0 5 15; do
        wait_enabled "$delay" || return 1
        mode=$(read_mode)
        if [ -z "$mode" ]; then
            log "$reason: audio service unavailable."
            continue
        fi
        if [ "$mode" != 6 ]; then
            log "$reason: applying BYPASS; observed hdmi_format=$mode"
            timeout 5 /system/bin/aparam set 0 hdmi_format=6 >> "$MODDIR/boot.log" 2>&1
            result=$?
            mode=$(read_mode)
            log "$reason: set exit=$result; readback hdmi_format='$mode'"
        fi
    done
    if [ "$mode" = 6 ]; then
        log "$reason checks complete: hdmi_format=6. Waiting for resume."
    else
        log "$reason checks failed: mode='$mode'. Will retry on the next resume."
    fi
}

reconcile Boot || exit 0

# Android event 2728 is emitted by PowerManagerService; [1,...] means on.
# Read only that structured event from the events buffer. No log clearing.
FIFO=/dev/firetv_audio_resume.$$.fifo
EVENT_PID=
cleanup() {
    if [ -n "$EVENT_PID" ]; then
        kill "$EVENT_PID" 2>/dev/null
        wait "$EVENT_PID" 2>/dev/null
    fi
    rm -f "$FIFO"
}
trap cleanup EXIT
trap 'exit 0' HUP INT TERM
mkfifo "$FIFO" || { log "Cannot create resume event pipe."; exit 1; }

while enabled; do
    # -T 1 also recovers the most recent event if the reader reconnects.
    # A replay may produce one harmless bounded reconciliation, not idle polling.
    /system/bin/logcat -b events -v raw -T 1 power_screen_state:I '*:S' > "$FIFO" 2>> "$MODDIR/boot.log" 9>&- &
    EVENT_PID=$!
    log "Resume listener started; no periodic HDMI checks."
    while IFS= read -r event; do
        enabled || break
        case "$event" in
            '[1,'*) reconcile Resume || break ;;
        esac
    done < "$FIFO"
    kill "$EVENT_PID" 2>/dev/null
    wait "$EVENT_PID" 2>/dev/null
    EVENT_PID=
    enabled || break
    log "Event stream ended; reconnecting in 30 seconds."
    wait_enabled 30 || break
done
log "Module disabled or removed; monitoring stopped."
