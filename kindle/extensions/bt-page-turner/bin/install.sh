#!/bin/sh
# bt-page-turner install.sh v0.1.0 — install or update everything, from the KUAL menu.
# Runs upstream's non-interactive installer, then our own steps (modules, kill switch,
# keep the library clean). KUAL waits for the script, so the work runs in the background
# and the result comes as a pop-up and in bt-page-turner.log.
. "$(dirname "$0")/common.sh"

if [ "$1" != "--bg" ]; then
    "$0" --bg > /dev/null 2>&1 &
    exit 0
fi

log "Install / update started" "開始安裝／更新"
if [ ! -f "$UPSTREAM/scripts/install.sh" ]; then
    log "ERROR: $UPSTREAM missing — copy the whole extension folder from the release zip" "錯誤：找不到 $UPSTREAM，請從 Release zip 完整複製插件資料夾"
    alert "BT Page Turner" "Install failed: upstream files missing. See bt-page-turner.log."
    exit 1
fi
alert "BT Page Turner" "Installing... this takes about a minute."
# Upstream's own installer (kindle-hid-passthrough, also installs the button mapper).
# No terminal → it asks nothing. Its output goes to our log for troubleshooting.
sh "$UPSTREAM/scripts/install.sh" installAll >> "$LOG" 2>&1
rc=$?
add_modules
tidy_library
patch_upstart
# Upstream restarts the daemons during install; the scriptlet removal above doesn't affect them.
if [ $rc -eq 0 ] && installed; then
    log "Install finished OK" "安裝完成"
    alert "BT Page Turner" "Installed. Next: KUAL > Bluetooth Page Turner > Pair, then Key mapping."
else
    log "Install finished with errors (upstream rc=$rc)" "安裝結束但有錯誤（上游結束碼 $rc），詳見本 log"
    alert "BT Page Turner" "Install finished with errors (rc=$rc). See bt-page-turner.log or run Diagnose."
fi
