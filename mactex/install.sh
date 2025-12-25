#!/usr/bin/env bash

set -euo pipefail

if [[ -f "$ZSH/001-lib/install-lib.sh" ]]; then
    # shellcheck source=../001-lib/install-lib.sh
    # shellcheck disable=SC1091
    source "$ZSH/001-lib/install-lib.sh"
fi

run_quiet() {
    local message="$1"
    shift
    local log_file
    log_file="$(mktemp -t mactex-install.XXXXXX)"
    if ! "$@" >"$log_file" 2>&1; then
        printf '%s\n' "$message" >&2
        cat "$log_file" >&2
        rm -f "$log_file"
        return 1
    fi
    rm -f "$log_file"
}

if command -v pdflatex >/dev/null 2>&1 && command -v xelatex >/dev/null 2>&1; then
    exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' "Error: Homebrew not found. Please install Homebrew first." >&2
    printf '%s\n' "Visit: https://brew.sh" >&2
    exit 1
fi

if command -v brew_install >/dev/null 2>&1; then
    run_quiet "Error: Failed to install MacTeX." brew_install --cask mactex
else
    run_quiet "Error: Failed to install MacTeX." brew install --cask mactex
fi