#!/usr/bin/env bash
# Runs only on the disposable GitHub-hosted Linux VM, before build dependencies are installed.
set -euo pipefail
[[ "${GITHUB_ACTIONS:-}" == true && "${RUNNER_OS:-}" == Linux ]] || {
    echo 'Runner cleanup requires GitHub Actions on Linux.' >&2
    exit 1
}
task_root="${GITHUB_WORKSPACE:?}"
mkdir -p "$task_root/artifacts"
report="$task_root/artifacts/runner-space.txt"
{
    date -Is
    printf '\nBefore cleanup\n'
    df -h / "$task_root" /mnt
    findmnt -T "$task_root"
    findmnt -T /mnt
} | tee "$report"

# Keep the runner, action runtimes, compilers, package manager and system libraries.
# These fixed SDK/cache locations are rebuilt with each new hosted VM.
for path in /usr/local/lib/android /usr/share/dotnet /opt/ghc /usr/local/.ghcup /usr/share/swift /opt/hostedtoolcache; do
    if [[ -d "$path" ]]; then
        sudo du -sh "$path" | tee -a "$report"
        sudo rm -rf -- "$path"
    fi
done
docker system prune -af
sudo apt-get clean
{
    printf '\nAfter cleanup\n'
    df -h / "$task_root" /mnt
} | tee -a "$report"
