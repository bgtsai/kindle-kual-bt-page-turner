#!/bin/sh
# bt-page-turner diagnose.sh v0.1.0 — read-only; writes diagnose.txt next to the menu.
# Copy it out over USB when something doesn't work (it holds no account data).
. "$(dirname "$0")/common.sh"
OUT="$EXT/diagnose.txt"
section() { echo; echo "===== $1 ====="; }
{
    echo "bt-page-turner diagnose v0.1.0  $(date)"
    section "firmware / kernel"
    cat /etc/prettyversion.txt 2>&1; cat /etc/version.txt 2>&1; uname -a 2>&1
    section "kill switch ($KILL)"
    if [ -e "$KILL" ]; then echo "PRESENT — daemons will not start at boot"; else echo "not present"; fi
    section "install"
    ls -l "$KHP/kindle-hid-passthrough" "$KBM/kindle-button-mapper" 2>&1
    ls "$UPSTREAM" 2>&1 | head -20
    section "kernel modules"
    ls -l /dev/uhid /dev/uinput 2>&1
    lsmod 2>&1 | grep -E "uhid|uinput|^Module" ; grep -E "uhid|uinput" /proc/modules 2>&1
    ls "$MODDIR" 2>&1 | grep zelda
    section "bluetooth hardware"
    ls -l /dev/ttymxc2 /dev/stpbt 2>&1
    ps 2>&1 | grep -E "bsa_server|kindle-hid|ld-linux|button-mapper" | grep -v grep
    section "upstart jobs"
    for j in $JOBS; do
        printf '%s: ' "$j"; status "$j" 2>&1 || initctl status "$j" 2>&1
        f="$ETC/upstart/$j.conf"
        if [ -f "$f" ]; then grep -q "$MARK" "$f" && echo "  $f: kill switch present" || echo "  $f: NO kill switch"; else echo "  $f: not installed"; fi
    done
    section "udev rules"
    ls -l "$ETC"/udev/rules.d/ 2>&1 | grep -E "hid|mapper"
    section "input devices (/proc/bus/input/devices)"
    cat /proc/bus/input/devices 2>&1
    section "paired devices (devices.conf)"
    cat "$KHP/devices.conf" 2>&1
    section "library leftovers"
    ls -l "$US/documents/BTManager.sh" "$US/documents/MapperManager.sh" 2>&1
    section "hid_passthrough.log (last 80 lines)"
    tail -n 80 /var/log/hid_passthrough.log 2>&1
    section "kindle-button-mapper.log (last 40 lines)"
    tail -n 40 /var/log/kindle-button-mapper.log 2>&1
    section "boot.log files"
    tail -n 20 "$KHP/boot.log" "$KBM/boot.log" "$EXT/boot.log" 2>&1
    section "bt-page-turner.log (last 80 lines)"
    tail -n 80 "$LOG" 2>&1
    echo; echo "===== end ====="
} > "$OUT" 2>&1
alert "BT Page Turner" "diagnose.txt written to extensions/bt-page-turner/"
