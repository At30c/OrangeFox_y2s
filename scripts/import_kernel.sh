#!/usr/bin/env bash
# Copies the LineageOS kernel built by HyOS990 (scripts/lineage_kernel.sh) into
# device/samsung/y2s/prebuilt/<variant>/ with its origin and hashes.
# By At30c, Apache-2.0.
#
# Usage: scripts/import_kernel.sh y2s|y2slte [HYOS990_DIR]
set -Eeuo pipefail
root=$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd)
variant=${1:?Usage: scripts/import_kernel.sh y2s|y2slte [HYOS990_DIR]}
[[ $variant == y2s || $variant == y2slte ]] || { echo "Error: unknown variant: $variant" >&2; exit 2; }
hyos=${2:-$root/../HyOS990}
src="$hyos/out/kernel/out-lineage/$variant"
dst="$root/device/samsung/y2s/prebuilt/$variant"
for f in Image dtb.img dtbo.img origin.txt SHA256SUMS; do
    [[ -f $src/$f ]] || { echo "Error: missing $src/$f (build it with HyOS990 scripts/lineage_kernel.sh $variant)" >&2; exit 1; }
done
(cd "$src" && sha256sum -c --quiet SHA256SUMS) || { echo "Error: $src does not match its SHA256SUMS" >&2; exit 1; }
mkdir -p "$dst"
cp -- "$src"/{Image,dtb.img,dtbo.img,origin.txt,SHA256SUMS} "$dst/"
printf 'Imported %s:\n' "$variant"
cat "$dst/SHA256SUMS"
