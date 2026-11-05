#!/bin/sh
# bt-page-turner pair.sh v0.1.0 — open upstream's BT Manager touchscreen app (scan, pair,
# connect, remove). Upstream normally opens it from a library book; the script itself
# needs nothing from the library, so KUAL can run it directly.
. "$(dirname "$0")/common.sh"
app="$KHP/illusion/BTManager.sh"
if [ ! -f "$app" ]; then
    alert "BT Page Turner" "Not installed yet. Run Install / update first."
    exit 1
fi
log "Opening BT Manager" "開啟藍牙配對介面"
sh "$app" > /dev/null 2>&1 &
exit 0
