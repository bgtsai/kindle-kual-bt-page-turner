# bt-page-turner common.sh v0.1.0 — shared paths and helpers (sourced, not run)
#
# This extension only installs, starts/stops and removes the upstream projects
# kindle-hid-passthrough (Bluetooth) and kindle-button-mapper (page turns); pairing and
# key mapping use their own touchscreen apps. Paths below are the upstream ones.
# BTPT_US / BTPT_ETC exist only so the cloud tests can point them at a temp tree.

US="${BTPT_US:-/mnt/us}"
ETC="${BTPT_ETC:-/etc}"
EXT="$US/extensions/bt-page-turner"
UPSTREAM="$EXT/upstream"                 # unpacked kindle-hid-passthrough release (in the zip)
KHP="$US/kindle_hid_passthrough"         # upstream install dir
KBM="$US/kindle-button-mapper"           # button mapper install dir (installed by upstream)
MODDIR="$KHP/dist/kindle_hid_passthrough/modules"
LOG="$EXT/bt-page-turner.log"
# Kill switch: an empty file with this name at the drive root stops both daemons at boot
# (checked in the pre-start of their upstart jobs, see patch_upstart). For a Kindle that
# no longer reaches the library: create it over USB and reboot.
KILL="$US/BT_DISABLE"
JOBS="hid-passthrough kindle-button-mapper"
MARK="bt-page-turner BT_DISABLE"

log() {
    # 2 lines: English first, Chinese second (same style as the other bgtsai KUAL extensions)
    printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG"
    [ -n "$2" ] && printf '                     Chinese | %s\n' "$2" >> "$LOG"
    return 0
}

# Pop-up on the Kindle (same lipc call the upstream scripts use). English only:
# untested whether the pillow alert renders Chinese.
alert() {
    t=$(printf '%s' "$1" | sed 's/"/\\"/g')
    m=$(printf '%s' "$2" | sed 's/"/\\"/g')
    lipc-set-prop com.lab126.pillow pillowAlert "{ \"clientParams\":{ \"alertId\":\"appAlert1\", \"show\":true, \"customStrings\":[ { \"matchStr\":\"alertTitle\", \"replaceStr\":\"$t\" }, { \"matchStr\":\"alertText\", \"replaceStr\":\"$m\" } ] } }" 2>/dev/null || true
}

installed() { [ -x "$KHP/kindle-hid-passthrough" ]; }

# Insert the kill-switch check as the first line of each upstart job's pre-start.
# Idempotent (skips a file that already has MARK); writes the system partition only when
# something changes. Upstream rewrites these files on every install / autostart toggle,
# so every such step calls this again.
patch_upstart() {
    need=""
    for j in $JOBS; do
        f="$ETC/upstart/$j.conf"
        [ -f "$f" ] && ! grep -q "$MARK" "$f" && need="$need $f"
    done
    [ -z "$need" ] && return 0
    mntroot rw
    for f in $need; do
        awk -v mark="$MARK" -v kill="$KILL" -v ext="$EXT" '
            { print }
            /^pre-start script/ && !done {
                print "    # " mark ": empty file at the drive root = do not start (rescue over USB)"
                print "    if [ -e " kill " ]; then echo \"$(date) " kill " present, not starting\" >> " ext "/boot.log; stop; exit 0; fi"
                done = 1
            }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
        if grep -q "$MARK" "$f"; then
            log "kill switch added to $f" "已在 $f 加入緊急停用檢查"
        else
            log "WARNING: could not add kill switch to $f (no pre-start script?)" "警告：無法在 $f 加入緊急停用檢查"
        fi
    done
    mntroot ro
}

# Upstream's installer also puts its two touchscreen apps into the library as books and
# adds its own KUAL entry. Decided with the user (2026-11-05): nothing of this extension
# shows in the library — the apps open from our KUAL menu instead.
tidy_library() {
    for f in "$US/documents/BTManager.sh" "$US/documents/MapperManager.sh"; do
        [ -f "$f" ] && rm -f "$f" && log "removed $f from the library" "已從書庫移除 $f"
    done
    if [ -d "$US/extensions/kindle-hid-passthrough" ]; then
        rm -rf "$US/extensions/kindle-hid-passthrough"
        log "removed upstream KUAL entry" "已移除上游的 KUAL 選單"
    fi
    return 0
}

# Our uhid.ko / uinput.ko built for firmware 5.13.5 (build 371676, zelda). Upstream loads
# the file whose name matches /etc/version.txt first, so ours wins on that build and
# upstream's own modules are still tried on others. Upstream replaces dist/ on every
# install, so this runs after each install.
add_modules() {
    [ -d "$MODDIR" ] || { log "WARNING: $MODDIR missing, modules not added" "警告：找不到 $MODDIR，未加入模組"; return 1; }
    for m in "$EXT"/modules/*.ko; do
        [ -f "$m" ] || continue
        cp "$m" "$MODDIR/" && log "added module $(basename "$m")" "已加入模組 $(basename "$m")"
    done
}
