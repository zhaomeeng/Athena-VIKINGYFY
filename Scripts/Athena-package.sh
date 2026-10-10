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
    'etc/openclash/core/clash_meta' 'etc/init.d/openclash' 'etc/init.d/passwall2' \
    'usr/share/passwall2/0_default_config' 'usr/bin/xray' 'usr/bin/sing-box' \
    'usr/bin/dockerd' 'usr/bin/docker' 'etc/uci-defaults/99-athena-services'; do
    grep -Fq "$path" "$out/athena-rootfs.txt" || { echo "Missing Athena rootfs path: $path" >&2; exit 1; }
done
# Pinned IPQ6018 revision 0c817c4 uses MDT metadata and split firmware segments.
for name in q6_fw.b00 q6_fw.b01 q6_fw.b02 q6_fw.b03 q6_fw.b04 q6_fw.b05 q6_fw.b07 q6_fw.b08 \
    m3_fw.b00 m3_fw.b01 m3_fw.b02; do
    "$unsquashfs_bin" -o 6291456 -cat "$factory_image" "lib/firmware/IPQ6018/$name" > "$out/firmware-segment.tmp"
    [[ -s "$out/firmware-segment.tmp" ]] || { echo "Empty IPQ6018 segment: $name" >&2; exit 1; }
done
rm -- "$out/firmware-segment.tmp"
if grep -Eq 'squashfs-root/etc/(init.d/passwall|config/passwall)([[:space:]]|$)' "$out/athena-rootfs.txt"; then
    echo 'Excluded PassWall 1 files found in Athena rootfs.' >&2; exit 1
fi
"$unsquashfs_bin" -o 6291456 -cat "$factory_image" etc/uci-defaults/99-athena-services > "$out/service-defaults.txt"
for line in "uci -q set openclash.config.enable='0'" "uci -q set passwall2.@global[0].enabled='0'" \
    'for service in openclash passwall2 passwall2_server xray sing-box dockerd; do'; do
    grep -Fxq "$line" "$out/service-defaults.txt" || { echo 'Missing service shutdown default.' >&2; exit 1; }
done
cp "$out/service-defaults.txt" upload/
cp "$out/athena-rootfs.txt" upload/
for database in lib/apk/db/installed usr/lib/opkg/status; do
    if grep -Fq "squashfs-root/$database" "$out/athena-rootfs.txt"; then
        "$unsquashfs_bin" -o 6291456 -cat "$factory_image" "$database" > upload/athena-packages.db
    fi
done
[[ -s upload/athena-packages.db ]]
for name in luci-app-openclash luci-app-passwall2 luci-i18n-passwall2-zh-cn xray-core sing-box docker dockerd; do
    grep -Eq "^(P:$name|Package: $name)$" upload/athena-packages.db || {
        echo "Required image package missing: $name" >&2; exit 1;
    }
done
for name in luci-app-passwall sing-box-tiny shadowsocks-rust-sslocal shadowsocks-rust-ssserver \
    shadowsocks-rust-ssmanager shadowsocks-rust-ssservice shadowsocks-rust-ssurl; do
    if grep -Eq "^(P:$name|Package: $name)$" upload/athena-packages.db; then
        echo "Excluded image package: $name" >&2; exit 1
    fi
done
printf 'PASS: Athena firmware, OpenClash/Mihomo, PassWall2/Xray/Sing-box, Docker and service defaults inspected.\n' \
    | tee "$out/image-validation.txt"
cp "$out/image-validation.txt" upload/
find "$target" -maxdepth 1 -type f \( -name '*.manifest' -o -name '*buildinfo' -o -name 'profiles.json' \) -exec cp {} upload/ \;
# Retain generated package repositories, including modules and APK/IPK metadata.
tar -czf upload/packages.tar.gz bin/packages "$target/packages"
find "$target" -name '*jdcloud_re-cs-02*manifest' -exec cat {} \; > "$out/athena.manifest"
if [[ -s "$out/athena.manifest" ]]; then
    cp "$out/athena.manifest" upload/
fi
(cd upload && find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%P\0' | sort -z | xargs -0 sha256sum > "$out/release.SHA256SUMS")
mv "$out/release.SHA256SUMS" upload/SHA256SUMS
