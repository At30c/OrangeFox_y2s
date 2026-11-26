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
  `TW_DEVICE_VERSION=HyOS990`, brightness 0..486 (LineageOS kernel: `BRT_SCALE` 1, because
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
  whole number (`orangefox.mk:30`); set to 1.

Pending: a successful workflow run, then test on the
device (boot, touch, brightness, MTP, adb, mounting the `_a` partitions, Format Data features with
`dump.f2fs`), and calibrate `OF_STATUS_H` to the camera hole.
