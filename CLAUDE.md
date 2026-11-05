# CLAUDE.md — notes for AI assistants

KUAL extension that installs and manages [kindle-hid-passthrough](https://github.com/zampierilucas/kindle-hid-passthrough) (userspace Bluetooth HID host, Bumble + UHID) and the [kindle-button-mapper-rs](https://github.com/zampierilucas/kindle-button-mapper-rs) it bundles (page turns in the native reader), so a jailbroken Kindle gets a Bluetooth page turner **without SSH and without anything in the library**. GPL-3.0 (upstream is GPL-3.0-or-later).

The user's goal is ease of use for non-technical people: copy a folder, tap a KUAL button. No SSH, no library books.

## Status

- v0.1.0 (2026-11-05): first version. Cloud-tested only (busybox sh with a fake upstream installer and stubbed `mntroot`/`lipc-set-prop`/`stop`): install → modules added, library books and upstream KUAL entry removed, kill switch inserted into both upstart jobs (idempotent), autostart on/off, uninstall; the inserted pre-start lines run and stop before upstream's boot counter. **Never run on a device.**
- Upstream pinned in `.github/workflows/release.yml`: kindle-hid-passthrough v3.19.0 (sha256 checked), bundled button mapper v1.8.0. The release zip = `kindle/` + upstream release unpacked into `extensions/bt-page-turner/upstream/` + LICENSE/notices. Both upstream source archives are attached to each release.

## Layout

```
kindle/extensions/bt-page-turner/      = what goes to the Kindle (release adds upstream/)
├── config.xml            <version> = release tag; bump on every change
├── menu.json             static menu (one top item 藍牙翻頁器, submenu)
├── modules/              uhid.ko + uinput.ko for 5.13.5 build 371676 zelda (docs/uhid-build.md)
└── bin/
    ├── common.sh         paths, log() (EN + 中文), alert() (pillow, English), patch_upstart, tidy_library, add_modules
    ├── install.sh        background: upstream `install.sh installAll` → add_modules → tidy_library → patch_upstart
    ├── pair.sh           runs upstream illusion/BTManager.sh (registers + opens the WAF app via lipc/sqlite)
    ├── mapping.sh        runs kindle-button-mapper/illusion/MapperManager.sh
    ├── daemon.sh         upstream scripts/hid-passthrough-daemon.sh start|stop
    ├── autostart.sh      upstream installUpstart (+ patch_upstart) / removeUpstart
    ├── diagnose.sh       read-only → diagnose.txt
    └── uninstall.sh      background: upstream uninstallAll + tidy_library
```

## Decisions (agreed with the user, don't change without asking)

- Upstream does all Bluetooth / mapping / UI work; this extension only installs, starts/stops, removes and rescues. Don't reimplement upstream features.
- Nothing in the library: upstream copies `BTManager.sh` / `MapperManager.sh` into `documents/` and creates its own KUAL entry `extensions/kindle-hid-passthrough` — `tidy_library` removes them after every upstream install step; the apps open from our KUAL items.
- Rescue, two layers: (1) KUAL ▸ Uninstall everything; (2) empty `BT_DISABLE` at the drive root + reboot → both upstart jobs stop in pre-start (line inserted by `patch_upstart`, marker `bt-page-turner BT_DISABLE`). No library "emergency" book (the user dropped it: if the library opens, KUAL opens).
- Start on boot stays off by default (as upstream).
- Upstream rewrites its upstart files on install/autostart → `patch_upstart` must run after each such call.

## Model-specific parts — check against the user's diagnose.txt

| Part | Where | What to check |
| --- | --- | --- |
| uhid/uinput modules | `modules/`, `add_modules` | `kernel modules` section: `/dev/uhid` exists after Start, `uhid` in /proc/modules. Upstream loads `{mod}-{uname -r}-{build}-{codename}.ko`, exact build first, then other builds of the same codename. Other firmware: build a matching module (`docs/uhid-build.md`) or rely on upstream's. **Unverified on device.** |
| BT chip takeover | upstream | `bluetooth hardware`: `/dev/ttymxc2` (Broadcom, 8th–10th gen) or `/dev/stpbt` (MediaTek); `hid_passthrough.log`. |
| Kill switch line | `common.sh` `patch_upstart` | `upstart jobs` section says "kill switch present" for both jobs. Relies on upstream's confs having a `pre-start script` line. |
| Opening the WAF apps from KUAL | `pair.sh`, `mapping.sh` | **Unverified**: upstream only launches them from library books (Hotfix scriptlets). |
| Pillow alert text | `common.sh` `alert` | English only; Chinese untested. |

## After editing

1. `sh -n` and `busybox sh -n` every `bin/*.sh`; JSON/XML check of `menu.json` / `config.xml`.
2. Bump `<version>` in `config.xml` and the `vX.Y.Z` header of each changed script.
3. Rerun the stub test (fake `upstream/scripts/install.sh` simulating installAll/installUpstart/removeUpstart/uninstallAll; stubs for `mntroot`, `lipc-set-prop`, `stop`; `BTPT_US`/`BTPT_ETC` point at a temp tree).
4. Changing the upstream version: update `KHP_TAG`, `KHP_SHA256`, `KBM_TAG` in the workflow and the versions in `THIRD_PARTY_NOTICES.md`; reread upstream `scripts/install.sh` (paths, action names, `documents/` copies, KUAL entry) before trusting the old wrapper.
5. Tell the user what was verified in the cloud vs. only on the device.
