#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")" || exit 1

command -v mise >/dev/null 2>&1 || brew install --quiet mise

if [[ -f .nvmrc ]]; then
    mise install
fi

node_version="$(tr -d '[:space:]' < .nvmrc)"
node_version="${node_version#v}"
mise exec "node@${node_version}" -- npm install -g --silent @augmentcode/auggie
mise exec "node@${node_version}" -- auggie --version >/dev/null
