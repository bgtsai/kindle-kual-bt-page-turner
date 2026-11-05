[切換中文](README.zh-TW.md)

# kindle-kual-bt-page-turner

A KUAL extension that makes a Bluetooth page-turner remote turn pages in the **native reader** of a jailbroken Kindle. No SSH, no KOReader: copy a folder to the Kindle, tap Install in KUAL.

All Bluetooth and page-turn functionality comes from Lucas Zampieri's [kindle-hid-passthrough](https://github.com/zampierilucas/kindle-hid-passthrough) and [kindle-button-mapper-rs](https://github.com/zampierilucas/kindle-button-mapper-rs). This extension only:

- bundles the upstream programs, so there is nothing else to download
- replaces upstream's SSH install steps with a KUAL button
- opens the pairing and key-mapping apps from KUAL, so **nothing is added to your library**
- removes everything with one tap, and gives a USB rescue for a Kindle that can't reach the library
- ships kernel modules for Kindle Oasis 2 firmware 5.13.5 (upstream has none for that build)

> **Tested on:** Kindle Oasis 2, firmware 5.13.5 (build 371676), with a programmable two-key Bluetooth keyboard: KUAL install, opening the pairing and key-mapping apps from KUAL, and page turns in the native reader are verified (2026-11-05). Other models upstream supports should work too — see [Notes for AI](#notes-for-ai).

## Requirements

- A **jailbroken** Kindle with **KUAL**
- A Bluetooth page-turner remote (upstream's [compatibility list](https://github.com/zampierilucas/kindle-hid-passthrough/blob/main/docs/compatibility.md); some remotes only work in BLE mode)
- A USB cable

## Installation

1. Download **`bt-page-turner.zip`** from [Releases](../../releases/latest) and unzip it.
2. Connect the Kindle and copy the unzipped **`extensions`** folder to the root of the Kindle drive (merging with the existing `extensions`).
3. Eject, open KUAL ▸ **藍牙翻頁器** ▸ **Install / update**.
4. Wait about a minute until "Installed" pops up.

Updating: copy the new version the same way and tap **Install / update** again. Paired devices and key mappings are kept.

## First use (once)

### 0. Choose what the remote sends (only for programmable remotes / mini keyboards)

Suggested: **next-page button = Page Down, previous-page button = Page Up**. Any key works (step 2 records whatever you press); these two just won't type characters into a search box if the mapper isn't running. Non-programmable page turners: use them as they are.

### 1. Pair

1. Put the remote in pairing mode (usually hold a button until the light blinks fast — see its manual).
2. KUAL ▸ 藍牙翻頁器 ▸ **Pair**: KUAL closes and the pairing app (BT Manager) opens.
3. Scan, tap your remote in the list, pair. If the same device shows up as both BLE and Classic, try BLE first.

### 2. Choose which button turns the page

1. KUAL ▸ 藍牙翻頁器 ▸ **Key mapping** opens Mapper Manager.
2. **Bindings** tab ▸ **+ Add** ▸ **Capture btn**, then press the remote button for "next page".
3. In the action list, pick the **Kindle** tab ▸ **next page** (`next_page`).
4. Again: **+ Add** ▸ **Capture btn** ▸ press the "previous page" button ▸ **Kindle** tab ▸ **previous page** (`prev_page`).

Notes:
- **Don't** pick Page Up / Page Down from the **Keyboard** tab: that sends another key, it doesn't turn the page.
- `next_page_tap` / `prev_page_tap` (a tap near the screen edges) are only for when the plain page turn does nothing.
- If you also read in KOReader, use the **Auto** tab's next / previous page: it sends the right command for whichever reader is on screen.
- **One press turns two pages**: in the **Device** tab, set the remote to exclusive (grab).

### Everyday use

- While the Bluetooth daemon runs, the remote connects by itself when switched on — no re-pairing.
- Start on boot is **off** by default: after a reboot, tap KUAL ▸ 藍牙翻頁器 ▸ **Start** first, or turn on Start on boot.
- The key-mapping daemon (upstream design) starts at every boot regardless of that switch; it is lightweight and just waits for input.

## Menu

KUAL ▸ **藍牙翻頁器**:

| Item | What it does |
| --- | --- |
| Install / update | Install or update everything (runs in the background, pops up when done) |
| Pair | Opens upstream's BT Manager: scan, pair, connect, remove devices |
| Key mapping | Opens upstream's Mapper Manager: which button = next / previous page |
| Start / Stop | Start or stop the Bluetooth daemon now |
| Start on boot: on / off | Start the Bluetooth daemon at boot. Default **off**: tap Start before use |
| Diagnose | Writes system info to `diagnose.txt` (read-only) |
| Uninstall everything | Removes everything upstream installed (keeps the list of paired devices) |

## If something goes wrong

| Situation | What to do |
| --- | --- |
| Library and KUAL still open | KUAL ▸ 藍牙翻頁器 ▸ **Uninstall everything** |
| Library doesn't open (white screen, reboot loop) | Over USB, create an empty file **`BT_DISABLE`** (no extension) at the root of the Kindle drive, then reboot. Neither the Bluetooth nor the key-mapping daemon starts. Once you're back in, tap Uninstall everything, then delete `BT_DISABLE` |

Upstream also protects itself: with start on boot on, three boots in a row without a stable run turn start on boot off.

Not covered: if the Kindle is broken badly enough that the USB drive doesn't show up, none of this helps — only upstream's SSH way ([usbnetlite](https://github.com/notmarek/kindle-usbnetlite) on older models) or a factory reset. Upstream's programs start late in boot, so this is unlikely, but not impossible.

## Files it creates

| File | Where | What |
| --- | --- | --- |
| `bt-page-turner.log` | `extensions/bt-page-turner/` | Log of every action (English + Chinese), incl. upstream installer output |
| `diagnose.txt` | `extensions/bt-page-turner/` | Output of Diagnose |
| `kindle_hid_passthrough/`, `kindle-button-mapper/` | drive root | Upstream programs and settings (paired devices in `kindle_hid_passthrough/devices.conf`) |
| udev rules, `hid-passthrough.conf`, `kindle-button-mapper.conf` | `/etc/` (system partition, not visible over USB) | Installed by upstream; this extension adds the `BT_DISABLE` check to the two boot jobs |

## Known limitations

- While the Bluetooth daemon runs, the Kindle's own Bluetooth (Audible) can't be used (upstream limitation).
- Battery use with the daemon always running, and whether the remote still works right after waking from sleep, aren't tested yet.
- Copying to the Kindle: if small files copy but files of a few MB hang and the Kindle drive keeps disconnecting and reconnecting, it's usually the USB cable — try another one (this happened).

## Uninstall

KUAL ▸ 藍牙翻頁器 ▸ **Uninstall everything**, then delete `extensions/bt-page-turner/` over USB.

## Notes for AI

See [CLAUDE.md](CLAUDE.md): model-specific parts, how to change the upstream version, how the modules were built.

## License

GPL-3.0, see [LICENSE](LICENSE). Bundled upstream programs and kernel modules: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md); both upstream source archives are attached to every release.
