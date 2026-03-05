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
    if [[ "$(nvm version "$node_version" 2>/dev/null)" == "N/A" ]]; then
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
