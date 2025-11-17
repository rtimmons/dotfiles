#!/usr/bin/env bash
set -eou pipefail

cd "$(dirname "$0")" || exit 1

# shellcheck source=/dev/null
source "$(brew --prefix nvm)/libexec/nvm.sh"

if [[ -f .nvmrc ]]; then
    desired_node="$(tr -d '[:space:]' < .nvmrc)"
    if [[ -n "$desired_node" && "$(nvm version "$desired_node" 2>/dev/null)" == "N/A" ]]; then
        nvm install "$desired_node"
    fi
fi

"$(brew --prefix nvm)/libexec/nvm-exec" npm install -g --silent @augmentcode/auggie

command -v auggie >/dev/null
