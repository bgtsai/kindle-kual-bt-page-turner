#!/bin/sh
# bt-page-turner daemon.sh v0.1.0 — start / stop the Bluetooth daemon now
# (upstream's scripts/hid-passthrough-daemon.sh, which also shows its own pop-up).
. "$(dirname "$0")/common.sh"
case "$1" in start|stop) ;; *) echo "usage: $0 start|stop" >&2; exit 2 ;; esac
if ! installed; then
    alert "BT Page Turner" "Not installed yet. Run Install / update first."
    exit 1
fi
log "Daemon $1" "藍牙背景程式：$1"
sh "$KHP/scripts/hid-passthrough-daemon.sh" "$1" >> "$LOG" 2>&1 &
exit 0
