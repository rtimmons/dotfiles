#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")" || exit 1

nvm_prefix="$(brew --prefix nvm)"

run_quiet() {
    local log_file
    log_file="$(mktemp -t claude-install.XXXXXX)"
    if ! "$@" >"$log_file" 2>&1; then
        cat "$log_file" >&2
        rm -f "$log_file"
        return 1
    fi
    rm -f "$log_file"
}

# shellcheck source=/dev/null
source "$nvm_prefix/libexec/nvm.sh"

if [[ -f .nvmrc ]]; then
    desired_node="$(tr -d '[:space:]' < .nvmrc)"
    if [[ -n "$desired_node" && "$(nvm version "$desired_node" 2>/dev/null)" == "N/A" ]]; then
        run_quiet nvm install "$desired_node"
    fi
fi

run_quiet "$nvm_prefix/nvm-exec" npm install -g @anthropic-ai/claude-code

command -v claude >/dev/null
