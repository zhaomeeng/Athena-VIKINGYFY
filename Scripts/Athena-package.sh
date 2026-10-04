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
    if [[ "$format" == factory ]]; then
        factory_image=${images[0]}
    fi
done
# The author's RE-CS-02 factory layout pads its kernel to 6144 KiB.
# Inspect the actual Athena root filesystem; platform-wide manifests omit some per-device packages.
unsquashfs_bin="$PWD/staging_dir/host/bin/unsquashfs4"
[[ -x "$unsquashfs_bin" ]]
"$unsquashfs_bin" -o 6291456 -ll "$factory_image" > "$out/athena-rootfs.txt"
for path in 'lib/firmware/ath11k/QCN9074/hw1.0/amss.bin' 'lib/firmware/IPQ6018/amss.bin' 'etc/openclash/core/clash_meta' 'etc/init.d/passwall2' 'usr/bin/dockerd' 'usr/bin/docker' 'etc/uci-defaults/99-athena-services'; do
    grep -Fq "$path" "$out/athena-rootfs.txt" || { echo "Missing Athena rootfs path: $path" >&2; exit 1; }
done
cp "$out/athena-rootfs.txt" upload/
for database in lib/apk/db/installed usr/lib/opkg/status; do
    if grep -Fq "squashfs-root/$database" "$out/athena-rootfs.txt"; then
        "$unsquashfs_bin" -o 6291456 -cat "$factory_image" "$database" > upload/athena-packages.db
    fi
done
find "$target" -maxdepth 1 -type f \( -name '*.manifest' -o -name '*buildinfo' -o -name 'profiles.json' \) -exec cp {} upload/ \;
# Retain generated package repositories, including modules and APK/IPK metadata.
tar -czf upload/packages.tar.gz bin/packages "$target/packages"
find "$target" -name '*jdcloud_re-cs-02*manifest' -exec cat {} \; > "$out/athena.manifest"
if [[ -s "$out/athena.manifest" ]]; then
    cp "$out/athena.manifest" upload/
fi
(cd upload && find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%P\0' | sort -z | xargs -0 sha256sum > SHA256SUMS)
