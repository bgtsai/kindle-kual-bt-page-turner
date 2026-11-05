#!/bin/sh
# bt-page-turner uninstall.sh v0.1.0 — remove everything upstream installed (its
# uninstallAll: daemon, udev rules, upstart jobs, apps, button mapper, install dir; it
# keeps paired devices). This extension's own folder stays; delete it over USB if wanted.
. "$(dirname "$0")/common.sh"
if [ "$1" != "--bg" ]; then
    "$0" --bg > /dev/null 2>&1 &
    exit 0
fi
log "Uninstall started" "開始全部移除"
if [ -f "$KHP/scripts/install.sh" ]; then
    sh "$KHP/scripts/install.sh" uninstallAll >> "$LOG" 2>&1
    rc=$?
elif [ -f "$UPSTREAM/scripts/install.sh" ]; then
    sh "$UPSTREAM/scripts/install.sh" uninstallAll >> "$LOG" 2>&1
    rc=$?
else
    rc=1
fi
tidy_library
if [ $rc -eq 0 ]; then
    log "Uninstall finished" "全部移除完成"
    alert "BT Page Turner" "Removed. You can delete extensions/bt-page-turner over USB."
else
    log "Uninstall finished with errors (rc=$rc)" "移除結束但有錯誤（結束碼 $rc）"
    alert "BT Page Turner" "Uninstall finished with errors (rc=$rc). See bt-page-turner.log."
fi
