[切換中文](README.zh-TW.md)

# kindle-kual-bt-page-turner

A KUAL extension that makes a Bluetooth page-turner remote turn pages in the **native reader** of a jailbroken Kindle. No SSH, no KOReader: copy a folder to the Kindle, tap Install in KUAL.

All Bluetooth and page-turn functionality comes from Lucas Zampieri's [kindle-hid-passthrough](https://github.com/zampierilucas/kindle-hid-passthrough) and [kindle-button-mapper-rs](https://github.com/zampierilucas/kindle-button-mapper-rs). This extension only:

- bundles the upstream programs, so there is nothing else to download
- replaces upstream's SSH install steps with a KUAL button
- opens the pairing and key-mapping apps from KUAL, so **nothing is added to your library**
- removes everything with one tap, and gives a USB rescue for a Kindle that can't reach the library
- ships kernel modules for Kindle Oasis 2 firmware 5.13.5 (upstream has none for that build)

> **Tested on:** scripts tested in the cloud only, **not on a real Kindle yet**. Target: Kindle Oasis 2, firmware 5.13.5. Other models upstream supports should work too — see [Notes for AI](#notes-for-ai).

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

1. KUAL ▸ 藍牙翻頁器 ▸ **Pair**: opens the pairing app. Put the remote in pairing mode, tap it in the list, pair.
2. KUAL ▸ 藍牙翻頁器 ▸ **Key mapping**: press the remote button you want as "next page" and pick Kindle's next page; do the same for "previous page".

From then on the remote connects by itself when it is switched on (while the Bluetooth daemon runs).

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
- Opening the pairing / key-mapping apps from KUAL is untested upstream; if it doesn't work, report with `diagnose.txt`.

## Uninstall

KUAL ▸ 藍牙翻頁器 ▸ **Uninstall everything**, then delete `extensions/bt-page-turner/` over USB.

## Notes for AI

See [CLAUDE.md](CLAUDE.md): model-specific parts, how to change the upstream version, how the modules were built.

## License

GPL-3.0, see [LICENSE](LICENSE). Bundled upstream programs and kernel modules: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md); both upstream source archives are attached to every release.
