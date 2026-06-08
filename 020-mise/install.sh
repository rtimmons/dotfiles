#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

brew install --quiet mise

run_quiet() {
    local log_file
    log_file="$(mktemp -t mise-install.XXXXXX)"
    if ! "$@" >"$log_file" 2>&1; then
        cat "$log_file" >&2
        rm -f "$log_file"
        return 1
    fi
    rm -f "$log_file"
}
export -f run_quiet

# Link our config so legacy .nvmrc files are respected
mkdir -p "$HOME/.config/mise"
config_src="$(pwd)/config.toml"
config_dst="$HOME/.config/mise/config.toml"
if [[ -L "$config_dst" && "$(readlink "$config_dst")" == "$config_src" ]]; then
    :
elif [[ ! -e "$config_dst" ]]; then
    ln -s "$config_src" "$config_dst"
else
    printf 'Warning: %s already exists; ensure it contains legacy_version_file = true\n' \
        "$config_dst" >&2
fi

# Pre-install all node versions found in repo .nvmrc files
repo_root="$(cd .. && pwd)"
find "$repo_root" -maxdepth 2 -name '.nvmrc' -print0 | while IFS= read -r -d '' nvmrc; do
    dir="$(dirname "$nvmrc")"
    (cd "$dir" && run_quiet mise install)
done
