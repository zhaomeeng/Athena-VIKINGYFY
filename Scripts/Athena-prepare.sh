#!/usr/bin/env bash
set -euo pipefail
task_root="${GITHUB_WORKSPACE:?}"
mkdir -p "$task_root/artifacts" files/etc/uci-defaults files/etc/openclash/core

# Pin every feed before invoking the original feed update/install sequence.
while IFS=$'\t' read -r kind name url revision; do
  [[ "$kind" == feed ]] || continue
  sed -i "s|^src-git $name .*|src-git $name $url^$revision|" feeds.conf.default
done < "$task_root/build.lock.tsv"
cp feeds.conf.default "$task_root/artifacts/feeds.conf.default"

cat > files/etc/uci-defaults/99-athena-services <<'EOF'
#!/bin/sh
# First boot is reserved for the wired / 80 MHz / 160 MHz baseline tests.
uci -q set openclash.config.enable='0'
uci -q commit openclash
uci -q set passwall2.@global[0].enabled='0'
uci -q commit passwall2
for service in openclash passwall2 dockerd; do
    [ ! -x "/etc/init.d/$service" ] || "/etc/init.d/$service" disable
done
exit 0
EOF
chmod 0755 files/etc/uci-defaults/99-athena-services

# OpenClash's LuCI package does not include a proxy core. Bundle the verified ARM64 release.
core_url=$(awk -F '\t' '$1=="binary" && $2=="mihomo" {print $3}' "$task_root/build.lock.tsv")
core_hash=$(awk -F '\t' '$1=="binary" && $2=="mihomo" {print $4}' "$task_root/build.lock.tsv")
curl --fail --location --retry 3 "$core_url" -o "$task_root/artifacts/mihomo.gz"
printf '%s  %s\n' "$core_hash" "$task_root/artifacts/mihomo.gz" | sha256sum -c -
gzip -dc "$task_root/artifacts/mihomo.gz" > files/etc/openclash/core/clash_meta
chmod 0755 files/etc/openclash/core/clash_meta
rm "$task_root/artifacts/mihomo.gz"
cp "$task_root/build.lock.tsv" "$task_root/artifacts/build.lock.tsv"
git rev-parse HEAD > "$task_root/artifacts/source-commit.txt"
git -C "$task_root" rev-parse HEAD > "$task_root/artifacts/framework-commit.txt"
