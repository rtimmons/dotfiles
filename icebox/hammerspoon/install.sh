#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HAMMERSPOON_DIR="${HOME}/.hammerspoon"

if ! brew list --cask hammerspoon >/dev/null 2>&1; then
    log="$(mktemp -t hammerspoon-install.XXXXXX)"
    if ! brew install --cask hammerspoon >"$log" 2>&1; then
        cat "$log" >&2
        rm -f "$log"
        exit 1
    fi
    rm -f "$log"
fi

if [[ -L "${HAMMERSPOON_DIR}" ]]; then
    current="$(readlink "${HAMMERSPOON_DIR}")"
    if [[ "${current}" != "${SCRIPT_DIR}" ]]; then
        rm "${HAMMERSPOON_DIR}"
        ln -sfn "${SCRIPT_DIR}" "${HAMMERSPOON_DIR}"
    fi
elif [[ -e "${HAMMERSPOON_DIR}" ]]; then
    mv "${HAMMERSPOON_DIR}" "${HAMMERSPOON_DIR}.backup"
    ln -sfn "${SCRIPT_DIR}" "${HAMMERSPOON_DIR}"
else
    ln -sfn "${SCRIPT_DIR}" "${HAMMERSPOON_DIR}"
fi
