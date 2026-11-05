#!/bin/sh
# bt-page-turner autostart.sh v0.1.0 — start on boot on / off (upstream installUpstart /
# removeUpstart). Off by default, as upstream: the daemon then runs only after Start.
# Upstream already stops autostart by itself after 3 boots without a stable run.
. "$(dirname "$0")/common.sh"
if ! installed; then
    alert "BT Page Turner" "Not installed yet. Run Install / update first."
    exit 1
fi
case "$1" in
    on)
        sh "$KHP/scripts/install.sh" installUpstart >> "$LOG" 2>&1
        patch_upstart
        log "Start on boot: on" "開機自動啟動：開"
        alert "BT Page Turner" "Start on boot: ON" ;;
    off)
        sh "$KHP/scripts/install.sh" removeUpstart >> "$LOG" 2>&1
        log "Start on boot: off" "開機自動啟動：關"
        alert "BT Page Turner" "Start on boot: OFF" ;;
    *) echo "usage: $0 on|off" >&2; exit 2 ;;
esac
