# OrangeFox for the Galaxy S20+ (y2s / y2slte) — HyOS990

OrangeFox Recovery (`fox_12.1`) for the Samsung Galaxy S20+ 5G (SM-G986B, `y2s`) and LTE
(SM-G985F, `y2slte`), made for the [HyOS990](https://github.com/At30c) HyperOS port. It replaces
the 2022 TWRP (`twrp_y2s-eng 11`), which formats `/data` without the F2FS project quota that
Android 17 needs and has an unreliable MTP.

## What is different from a stock S20 recovery

- **Kernel:** the LineageOS 24.0 kernel (`android_kernel_samsung_universal9830`) built by HyOS990
  (`scripts/lineage_kernel.sh`), with quota, casefold (`CONFIG_UNICODE`), F2FS compression, EROFS,
  FunctionFS (adb/MTP) and the HyOS990 series. One prebuilt set per model in
  `device/samsung/y2s/prebuilt/<variant>/` (`Image`, `dtb.img`, `dtbo.img`, `origin.txt`).
- **Format Data:** `emulated_storage.mk` sets `external_storage.projid.enabled` and
  `external_storage.casefold.enabled`, so `/data` is formatted with `project_quota,extra_attr`
  and casefold. Without the project quota, vold cannot set the project id of the app-specific
  directories (`Android/data/<package>`) and apps such as the Theme Manager fail with `EACCES`.
- **Partitions:** HyOS990 virtual A/B on `super`: the fstab uses the slot-a logical names
  (`system_a`, `system_ext_a`, `vendor_a`, `product_a`, `odm_a`, `mi_ext_a`, `system_dlkm_a`,
  `vendor_dlkm_a`), EROFS or ext4. `/data` is not encrypted in HyOS990.
- **Brightness:** 0..486 (the LineageOS kernel has no x100 brightness scale).

## Building

The build runs on GitHub Actions (`.github/workflows/build.yml`, manual run or a `v*` tag): it syncs
OrangeFox with the official sync script (`./orangefox_sync.sh --branch 12.1`), copies the device tree
and builds `recoveryimage` twice, once per `FOX_VARIANT`. The artifact (and the release, for a tag)
holds `OrangeFox_y2s_recovery.img`, `OrangeFox_y2slte_recovery.img`, the OrangeFox ZIPs and
`SHA256SUMS`.

Updating the prebuilt kernel after a HyOS990 kernel build:

```sh
scripts/import_kernel.sh y2s      # from ../HyOS990/out/kernel/out-lineage/y2s
scripts/import_kernel.sh y2slte
```

Local build (same steps as the workflow):

```sh
git clone https://gitlab.com/OrangeFox/sync.git && cd sync
./orangefox_sync.sh --branch 12.1 --path ~/fox_12.1
cp -r device/samsung/y2s ~/fox_12.1/device/samsung/y2s
cd ~/fox_12.1 && export FOX_VARIANT=y2slte && source build/envsetup.sh
lunch twrp_y2s-eng && mka adbd recoveryimage
```

## Installing

Flash the image of your model to the `RECOVERY` partition (Heimdall/Odin, or `dd` from a root
shell). The bootloader must be unlocked and `vbmeta` must have verification disabled (HyOS990
already flashes it with flags 3).

## Credits and licenses

- Device tree base: [ExtremeXT/android_device_samsung_x1s_TWRP](https://github.com/ExtremeXT/android_device_samsung_x1s_TWRP)
  (branch `android-12.1`, commit `e71fec03e4eb`), Copyright (C) 2024 The Android Open Source Project
  and The TWRP Open Source Project, Apache-2.0. The recovery firmware blobs in
  `recovery/root/vendor/firmware` come from the same tree (Samsung).
- OrangeFox Recovery Project: <https://gitlab.com/OrangeFox>.
- Kernel: LineageOS (`android_kernel_samsung_universal9830`, GPL-2.0) with the HyOS990 series.
- This repository: Apache-2.0 (`LICENSE`).

## State

Not built or tested yet. See `AGENTS.md` for the record and the pending items.
