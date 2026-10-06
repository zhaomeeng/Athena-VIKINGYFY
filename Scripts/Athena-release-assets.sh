#!/usr/bin/env bash
set -euo pipefail
# Keep the original Actions artifact intact. GitHub rejects zero-byte release
# assets, so preserve empty diagnostic files together in a nonempty tar archive.
source_dir=$(cd "${1:?artifact directory}" && pwd -P)
destination=${2:?new release directory}
[[ -s "$source_dir/SHA256SUMS" ]]
(cd "$source_dir"; sha256sum -c SHA256SUMS)
[[ ! -e "$destination" ]] || { echo 'Release directory already exists.' >&2; exit 1; }
mkdir -p "$destination"
destination=$(cd "$destination" && pwd -P)
while IFS= read -r -d '' asset; do
    cp -- "$asset" "$destination/"
done < <(find "$source_dir" -maxdepth 1 -type f ! -name SHA256SUMS -size +0c -print0)
empty_list="$destination/empty-files.list"
(cd "$source_dir"; find . -maxdepth 1 -type f ! -name SHA256SUMS -empty -printf '%P\0' | LC_ALL=C sort -z) > "$empty_list"
if [[ -s "$empty_list" ]]; then
    tar -czf "$destination/empty-evidence.tar.gz" -C "$source_dir" --null -T "$empty_list"
fi
rm -- "$empty_list"
checksum_file=$(mktemp)
trap 'rm -f -- "$checksum_file"' EXIT
(cd "$destination"; find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%P\0' | LC_ALL=C sort -z | xargs -0 sha256sum > "$checksum_file")
mv -- "$checksum_file" "$destination/SHA256SUMS"
(cd "$destination"; sha256sum -c SHA256SUMS)
