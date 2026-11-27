# Rules and record — OrangeFox_y2s

## Rules

1. Language: Brazilian Portuguese (pt-BR) is used **only** in the chat with the user. Code,
   identifiers, comments, program messages, file names, commit messages and documentation are
   written in English.
2. Document every change in the same delivery: this file (reason, files, checks, pending items)
   and the README when usage changes. Do not present planning as finished work.
3. This project is separate from HyOS990 so that the Android build system (repo, Python, Soong)
   stays out of HyOS990, whose no-Python rule still applies there. Our own scripts here are Bash.
4. Credit author, origin and license of everything that comes from third parties.
5. Never record passwords or personal data of the user.
6. Commit only when the user asks; messages end with
   `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
7. Never flash the device without the user's explicit request.

## Context

User decision (26/11/2026): replace the 2022 TWRP (`twrp_y2s-eng 11`, kernel 4.19.87) with an
OrangeFox built for HyOS990. Reasons: limited features, unreliable MTP, and `/data` formatted
without F2FS `project_quota`/`extra_attr` (that TWRP only adds them with
`external_storage.projid.enabled=1`, a property it does not set), which breaks the app-specific
storage directories on Android 17 (HyOS990 AGENTS, 26/11/2026). Choices: separate repository
`At30c/OrangeFox_y2s` (public), build on GitHub Actions, LineageOS kernel, both models.

## Record

### 26/11/2026 — Project created (not built yet)

- Device tree `device/samsung/y2s` from ExtremeXT's `android_device_samsung_x1s_TWRP`
  (`android-12.1`, `e71fec03e4eb`, Apache-2.0): `x1s` renamed to `y2s`.
- `recovery.fstab` rewritten for HyOS990: slot-a logical names (virtual A/B; checked on the device:
  `/dev/block/mapper/*_a`, `ro.boot.slot_suffix=_a`), `system_ext`, `mi_ext`, `system_dlkm` (ext4),
  `vendor_dlkm`; `/data` without `fileencryption`.
- `BoardConfig.mk`: prebuilt kernel per `FOX_VARIANT` (`prebuilt/y2s`, `prebuilt/y2slte`),
  `TW_DEVICE_VERSION=HyOS990`, brightness 0..486 (later corrected to 0..48600; LineageOS kernel: `BRT_SCALE` 1, because
  `CONFIG_PANEL_BACKLIGHT_PAC_3_0` is off), `TW_Y_OFFSET`/`TW_H_OFFSET` removed in favour of the
  OrangeFox status bar variables.
- `vendorsetup.sh`: OrangeFox variables (screen 2400, status bar 100, indents 48, clock left/right,
  no LED/flashlight, Samsung `SEANDROIDENFORCE`, MIUI features off, lptools).
- Checks done before choosing the kernel: both the LineageOS kernel and the HyOS990 system kernel
  (ExtremeKRNL) have `CONFIG_QUOTA` and `CONFIG_UNICODE`, so formatting `/data` with casefold and
  project quota does not break the system mount. In recovery, S-Boot passes `bootmode=2`, which
  the HyOS990 boot timer skips.
- `scripts/import_kernel.sh` copies `out/kernel/out-lineage/<variant>` from HyOS990 after
  checking its `SHA256SUMS`. `.github/workflows/build.yml` syncs fox_12.1 and builds both variants.

- Both kernels imported (y2slte Image `cec30627…9cdb`, y2s Image `14462c2b…752b`). The workflow
  builds y2slte first (the user's device) and skips a variant without an imported kernel.

- Repository `At30c/OrangeFox_y2s` created (public) and pushed. First run 45781259908 failed right
  after sourcing `build/envsetup.sh`: it is not written for the `bash -e` shell of GitHub Actions.
  The build step now loads it with `set +eu` and checks `lunch` and `mka` explicitly.
- Run 45782589023 reached the Soong analysis and stopped: `FOX_MAINTAINER_PATCH_VERSION` must be a
  whole number (`orangefox.mk:30`); set to 1. Run 45784126956 ran on the old commit (dispatched
  before the push landed).
- Run 45785438117 (commit `64ba186`) compiled the whole recovery in ~40 min and failed only on the
  size check: `recovery.img` 69,599,232 bytes > 68,939,776 (partition 69,009,408 minus the AVB
  footer). The LineageOS kernel is ~5.5 MB larger than the base tree's. `TW_EXTRA_LANGUAGES`
  (CJK fonts) dropped from `BoardConfig.mk`; pt_BR stays in the base language set.

- Run 45903263755 succeeded (both variants, artifacts in `out/run-45903263755/OrangeFox_y2s/`).
- Flashing it from TWRP failed: "image larger than the partition". The image was 69,009,424 bytes,
  16 more than the recovery partition (69,009,408, read on the device with `blockdev`):
  `FOX_USE_SAMSUNG_SPECIAL=1` appends `SEANDROIDENFORCE` after the AVB footer of an image already
  padded to the partition size (which also leaves the footer away from the end). Fix:
  `FOX_USE_SAMSUNG_SPECIAL=0` in `vendorsetup.sh` (not rebuilt yet). The artifacts were trimmed
  to 69,009,408 bytes in `out/run-45903263755/fixed/` (with `SHA256SUMS`); `avbroot avb verify`
  passes on them (hash descriptor and signature). The flashable ZIPs of that run were not changed.
- Installed on the device (OrangeFox boots). Brightness did not work: the panel driver of the
  LineageOS kernel reports `max_brightness` 48600 (x100 scale), so the earlier assumption of
  0..486 was wrong and the default 243 gave `actual_brightness` 3. Writing 24300 live was accepted
  (`actual_brightness` 403). `BoardConfig.mk` now uses `TW_MAX_BRIGHTNESS` 48600 and default
  24300 (not rebuilt yet).
- Commit `3f1f451` (size and brightness) pushed; run 45922573748 dispatched, then cancelled to
  include the fix below.
- MTP: the server started before the cable was plugged in, failed with ESHUTDOWN on the bulk
  endpoint and never retried (Mount > MTP off/on restarts it). After the restart the host opens
  the session and lists the storage, but listing objects hangs: the server waits on the bulk-out
  endpoint for a command that never arrives, also with `sys.usb.ffs.aio_compat=true` set live.
  Suspect: the dwc3/FunctionFS path of the LineageOS kernel. Not fixed; adb push/pull works.
- Logical partitions were never mapped by the recovery ("unable to update logical partition" for
  all of them, then "Unable to find partition for path '/system_root'" and "* No ROM"): without
  `AB_OTA_UPDATER`, `Prepare_Super_Volume` builds the name from the mount point ("vendor") and
  ignores the `vendor_a` written in the fstab. Our own patch
  `patches/bootable_recovery/0001-map-logical-partitions-by-fstab-name.patch` (against
  `fox_12.1` `partitionmanager.cpp`, checked with `patch --dry-run`) keeps a bare fstab name per
  mount point, also in `Unmap_Super_Devices`; the workflow applies the series after the sync.
  Making the recovery A/B instead was rejected: boot/recovery are not slotted on this device.
  Not compiled locally (no Android tree here). A ZIP install itself was unaffected (the updater
  maps `*_a` through libfs_mgr): `HyOS990_y2slte_20261126.zip` installed successfully.

Pending: a run with the fix, then test on the
device (boot, touch, brightness, MTP, adb, mounting the `_a` partitions, Format Data features with
`dump.f2fs`), and calibrate `OF_STATUS_H` to the camera hole.
