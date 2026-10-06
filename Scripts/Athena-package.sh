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
for path in 'lib/firmware/ath11k/QCN9074/hw1.0/amss.bin' 'lib/firmware/IPQ6018/q6_fw.mdt' \
    'lib/firmware/IPQ6018/m3_fw.mdt' 'lib/firmware/IPQ6018/board-2.bin' \
    'etc/openclash/core/clash_meta' 'etc/init.d/openclash' 'usr/bin/dockerd' 'usr/bin/docker' 'etc/uci-defaults/99-athena-services'; do
    grep -Fq "$path" "$out/athena-rootfs.txt" || { echo "Missing Athena rootfs path: $path" >&2; exit 1; }
done
# Pinned IPQ6018 revision 0c817c4 uses MDT metadata and split firmware segments.
for name in q6_fw.b00 q6_fw.b01 q6_fw.b02 q6_fw.b03 q6_fw.b04 q6_fw.b05 q6_fw.b07 q6_fw.b08 \
    m3_fw.b00 m3_fw.b01 m3_fw.b02; do
    "$unsquashfs_bin" -o 6291456 -cat "$factory_image" "lib/firmware/IPQ6018/$name" > "$out/firmware-segment.tmp"
    [[ -s "$out/firmware-segment.tmp" ]] || { echo "Empty IPQ6018 segment: $name" >&2; exit 1; }
done
rm -- "$out/firmware-segment.tmp"
if grep -Eq 'squashfs-root/etc/(init.d/passwall2?|config/passwall2?)([[:space:]]|$)' "$out/athena-rootfs.txt"; then
    echo 'Excluded PassWall files found in Athena rootfs.' >&2; exit 1
fi
cp "$out/athena-rootfs.txt" upload/
for database in lib/apk/db/installed usr/lib/opkg/status; do
    if grep -Fq "squashfs-root/$database" "$out/athena-rootfs.txt"; then
        "$unsquashfs_bin" -o 6291456 -cat "$factory_image" "$database" > upload/athena-packages.db
    fi
done
[[ -s upload/athena-packages.db ]]
for name in luci-app-passwall luci-app-passwall2 xray-core sing-box shadowsocks-rust-sslocal; do
    if grep -Eq "^(P:$name|Package: $name)$" upload/athena-packages.db; then
        echo "Excluded image package: $name" >&2; exit 1
    fi
done
find "$target" -maxdepth 1 -type f \( -name '*.manifest' -o -name '*buildinfo' -o -name 'profiles.json' \) -exec cp {} upload/ \;
# Retain generated package repositories, including modules and APK/IPK metadata.
tar -czf upload/packages.tar.gz bin/packages "$target/packages"
find "$target" -name '*jdcloud_re-cs-02*manifest' -exec cat {} \; > "$out/athena.manifest"
if [[ -s "$out/athena.manifest" ]]; then
    cp "$out/athena.manifest" upload/
fi
(cd upload && find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%P\0' | sort -z | xargs -0 sha256sum > "$out/release.SHA256SUMS")
mv "$out/release.SHA256SUMS" upload/SHA256SUMS
