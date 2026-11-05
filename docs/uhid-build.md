# How `modules/*.ko` were built

Kindle Oasis 2 kernels ship without `CONFIG_UHID` / `CONFIG_INPUT_UINPUT`. kindle-hid-passthrough
bundles modules for some firmware builds; firmware 5.13.5 (build 371676) wasn't one of them, so we
built these. Recipe from upstream `docs/uhid-research.md`, adapted (2026-11-05):

1. Source: `Kindle_src_5.13.5_3716760030.tar.gz` from Amazon's *Source Code Notice for Kindle
   E-Reader Devices* page (the first 6 digits of the number = the build in `/etc/version.txt`).
   Inside: `gplrelease/linux-4.1.15.tar.gz`.
2. Compiler: kernel.org crosstool `x86_64-gcc-4.9.4-nolibc-arm-linux-gnueabi.tar.xz`
   (Linaro 4.9.4, which upstream names, is no longer downloadable). On a current Linux it needs
   `libmpfr.so.4` → symlink to `libmpfr.so.6` and `LD_LIBRARY_PATH` pointing there.
3. ```
   export ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
   make imx_v7_zelda_defconfig
   scripts/config --module CONFIG_UHID --module CONFIG_INPUT_UINPUT \
                  --disable CONFIG_FB_MXC_EINK_V2_PANEL --disable CONFIG_FB_MXC_EINK_PANEL
   make olddefconfig
   make -j3 HOSTCFLAGS=-fcommon vmlinux modules   # -fcommon: new host gcc vs the old dtc
   ```
   Output: `drivers/hid/uhid.ko`, `drivers/input/misc/uinput.ko`.
4. Check: vermagic `4.1.15-lab126 SMP preempt mod_unload modversions ARMv7 p2v8`; `__versions`
   section present. The 34 symbol CRCs of our `uhid.ko` are identical to upstream's
   `uhid-4.1.15-lab126-409745-zelda.ko` (14 differ from the 443455 one).

File names follow upstream's lookup: `{uhid,uinput}-{uname -r}-{build}-{codename}.ko`.
