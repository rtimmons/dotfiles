#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")" || exit 1

# Ensure all repo-managed Node versions exist before PATH hooks rely on them.
# shellcheck source=/dev/null
source "$(brew --prefix nvm)/libexec/nvm.sh"

repo_root="$(cd .. && pwd)"

find "$repo_root" -maxdepth 2 -name '.nvmrc' -print0 | while IFS= read -r -d '' nvmrc; do
    node_version="$(tr -d '[:space:]' < "$nvmrc")"
    if [[ -z "$node_version" ]]; then
        continue
    fi
    if [[ "$(nvm version "$node_version" 2>/dev/null)" == "N/A" ]]; then
        nvm install "$node_version"
    fi
done
