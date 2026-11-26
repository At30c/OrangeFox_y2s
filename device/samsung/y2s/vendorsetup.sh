#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 The TWRP Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# For building with minimal manifest
export ALLOW_MISSING_DEPENDENCIES=true

# OrangeFox build variables for the Galaxy S20+ running HyOS990
# (https://gitlab.com/OrangeFox/infrastructure/doc/-/blob/main/dev/build_vars.md).
# FOX_VARIANT selects the model (y2s or y2slte); BoardConfig.mk uses it to pick prebuilt/<variant>.
export FOX_VARIANT="${FOX_VARIANT:-y2s}"
export OF_MAINTAINER="At30c"
export FOX_MAINTAINER_PATCH_VERSION="HyOS990"

# 1440x3200 (20:9): 20 * 120. Centered punch hole and rounded corners.
export OF_SCREEN_H=2400
export OF_STATUS_H=100
export OF_STATUS_INDENT_LEFT=48
export OF_STATUS_INDENT_RIGHT=48
export OF_CLOCK_POS=1
export OF_HIDE_NOTCH=1
export OF_ALLOW_DISABLE_NAVBAR=0

# No notification LED; the flashlight path is not mapped for this device yet.
export OF_USE_GREEN_LED=0
export OF_FLASHLIGHT_ENABLE=0

# Samsung: append SEANDROIDENFORCE to the recovery image (avoids the S-Boot warning).
export FOX_USE_SAMSUNG_SPECIAL=1

# Not a MIUI device: HyOS990 is HyperOS on Samsung hardware, without the Xiaomi bootloader flow.
export OF_DISABLE_MIUI_SPECIFIC_FEATURES=1
export OF_NO_TREBLE_COMPATIBILITY_CHECK=1

# Super partition tools (lpdump/lptools) for the logical partitions.
export OF_ENABLE_LPTOOLS=1
