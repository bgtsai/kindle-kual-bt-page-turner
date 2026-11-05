# Third-party notices

This extension (the scripts in `bin/`) is licensed under the GNU General Public License v3.0
(see `LICENSE`). The release zip also contains:

| Component | Where in the zip | License | Source |
| --- | --- | --- | --- |
| [kindle-hid-passthrough](https://github.com/zampierilucas/kindle-hid-passthrough) v3.19.0 by Lucas Zampieri — the official release `kindle-hid-passthrough-armv7.tar.xz`, unmodified | `extensions/bt-page-turner/upstream/` | GPL-3.0-or-later (`LICENSE`) | attached to each release of this repo (`kindle-hid-passthrough-v3.19.0-source.tar.gz`) and at the upstream tag |
| [kindle-button-mapper-rs](https://github.com/zampierilucas/kindle-button-mapper-rs) v1.8.0 by Lucas Zampieri — bundled inside the release above | `upstream/button-mapper/` | GPL-3.0-or-later (`LICENSE`) | attached to each release (`kindle-button-mapper-rs-v1.8.0-source.tar.gz`) |
| `uhid.ko`, `uinput.ko` — Linux kernel 4.1.15-lab126 modules built by us for Kindle firmware 5.13.5 (build 371676, Oasis 2 / zelda) | `extensions/bt-page-turner/modules/` | GPL-2.0 (Linux kernel) | Amazon's `Kindle_src_5.13.5_3716760030.tar.gz` (Source Code Notice for Kindle E-Reader Devices); configuration and steps in `docs/uhid-build.md` |

The upstream release also contains its own bundled runtime (Python, Google Bumble and system
libraries) as built by the upstream project; see the upstream repository for their licenses and
build recipe.
