#!/usr/bin/env bash

set -euo pipefail

install_tlrc() {
    local old_installed=0
    if brew list --formula tldr >/dev/null 2>&1; then
        old_installed=1
        brew unlink tldr || return 1
    fi

    if ! brew install --quiet tlrc; then
        if [[ "$old_installed" -eq 1 ]]; then
            brew link tldr
        fi
        return 1
    fi

    if [[ "$old_installed" -eq 1 ]]; then
        brew uninstall --formula tldr || return 1
    fi
    "$(brew --prefix)/bin/tldr" --update
}

log_file="$(mktemp -t tlrc-install.XXXXXX)"
trap 'rm -f "$log_file"' EXIT
if ! install_tlrc >"$log_file" 2>&1; then
    cat "$log_file" >&2
    exit 1
fi
