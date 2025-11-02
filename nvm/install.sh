#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

brew install --quiet nvm

mkdir -p "$HOME/.nvm"

# shellcheck source=/dev/null
source "$(brew --prefix nvm)/libexec/nvm.sh"

repo_root="$(cd .. && pwd)"

process_dir() {
    local dir="$1"
    local nvmrc="$dir/.nvmrc"
    if [[ ! -f "$nvmrc" ]]; then
        return
    fi
    local node_version
    node_version="$(tr -d '[:space:]' < "$nvmrc")"
    if [[ -z "$node_version" ]]; then
        return
    fi
    local rel_dir
    if [[ "$dir" == "$repo_root" ]]; then
        rel_dir="."
    else
        rel_dir="${dir#"$repo_root"/}"
    fi
    if [[ "$(nvm version "$node_version" 2>/dev/null)" == "N/A" ]]; then
        printf 'Installing Node %s via nvm (from %s)\n' \
            "$node_version" "$rel_dir"
        (
            cd "$dir"
            nvm install
        )
    fi
}

process_dir "$repo_root"
shopt -s nullglob
for dir in "$repo_root"/*/; do
    process_dir "${dir%/}"
done
shopt -u nullglob
