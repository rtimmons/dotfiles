#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")" || exit 1

run_quiet() {
    local log_file
    log_file="$(mktemp -t codex-install.XXXXXX)"
    if ! "$@" >"$log_file" 2>&1; then
        cat "$log_file" >&2
        rm -f "$log_file"
        return 1
    fi
    rm -f "$log_file"
}

if [[ -f .nvmrc ]]; then
    run_quiet mise install
fi

node_version="$(tr -d '[:space:]' < .nvmrc)"
node_version="${node_version#v}"
run_quiet mise exec "node@${node_version}" -- npm install -g --silent @openai/codex
run_quiet mise exec "node@${node_version}" -- codex --version
