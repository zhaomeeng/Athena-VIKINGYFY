#!/usr/bin/env bash
set -euo pipefail
task_root="${GITHUB_WORKSPACE:?}"
out="$task_root/artifacts"
target=bin/targets/qualcommax/ipq60xx
mkdir -p upload
cp "$out"/* upload/
cp .config upload/final.config
for format in factory sysupgrade; do
    mapfile -t images < <(find "$target" -maxdepth 1 -type f -name "*jdcloud_re-cs-02*${format}*")
    [[ ${#images[@]} -eq 1 ]] || { echo "Expected one Athena $format image, got ${#images[@]}" >&2; exit 1; }
    cp "${images[0]}" upload/
done
find "$target" -maxdepth 1 -type f \( -name '*.manifest' -o -name '*buildinfo' -o -name 'profiles.json' \) -exec cp {} upload/ \;
# Retain generated package repositories, including modules and APK/IPK metadata.
tar -czf upload/packages.tar.gz bin/packages "$target/packages"
find "$target" -name '*jdcloud_re-cs-02*manifest' -exec cat {} \; > "$out/athena.manifest"
if [[ -s "$out/athena.manifest" ]]; then
    cp "$out/athena.manifest" upload/
fi
(cd upload && sha256sum -- * > SHA256SUMS)
