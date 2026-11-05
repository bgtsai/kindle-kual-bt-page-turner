#!/bin/sh
# bt-page-turner mapping.sh v0.1.0 — open upstream's Mapper Manager touchscreen app
# (which remote button = next / previous page). Same idea as pair.sh.
. "$(dirname "$0")/common.sh"
app="$KBM/illusion/MapperManager.sh"
if [ ! -f "$app" ]; then
    alert "BT Page Turner" "Not installed yet. Run Install / update first."
    exit 1
fi
log "Opening Mapper Manager" "開啟按鍵對應介面"
sh "$app" > /dev/null 2>&1 &
exit 0
