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
    log_file="$(mktemp -t merdoc-install.XXXXXX)"
    if ! "$@" >"$log_file" 2>&1; then
        printf '%s\n' "$message" >&2
        cat "$log_file" >&2
        rm -f "$log_file"
        return 1
    fi
    rm -f "$log_file"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"
FILTER_DIR="$SCRIPT_DIR/pandoc-ext-diagram"

run_quiet "Warning: Failed to install pandoc." brew_install pandoc
run_quiet "Warning: Failed to install fswatch." brew_install fswatch

if command -v python3 >/dev/null 2>&1; then
    if [[ ! -d "$VENV_DIR" ]]; then
        if ! run_quiet "Warning: Could not create virtual environment. Live reload may not work." \
            python3 -m venv "$VENV_DIR"; then
            VENV_DIR=""
        fi
    fi

    if [[ -n "${VENV_DIR:-}" && -f "$VENV_DIR/bin/python" ]]; then
        run_quiet "Warning: Could not upgrade pip in virtual environment." \
            "$VENV_DIR/bin/python" -m pip install --upgrade pip
        run_quiet "Warning: Could not install websockets library. Live reload may not work." \
            "$VENV_DIR/bin/python" -m pip install websockets
    fi
fi

if [[ "${MERDOC_INSTALL_MACTEX:-}" == "1" ]] && ! command -v pdflatex >/dev/null 2>&1; then
    run_quiet "Warning: Failed to install MacTeX." brew_install --cask mactex
fi

run_quiet "Warning: Failed to ensure required Node version." \
    ensure_desired_node "$SCRIPT_DIR"

if ! command -v mmdc >/dev/null 2>&1; then
    run_quiet "Warning: Failed to install mermaid CLI." \
        npm install -g @mermaid-js/mermaid-cli
fi

mkdir -p "$SCRIPT_DIR/bin"

if [[ ! -d "$FILTER_DIR" ]]; then
    run_quiet "Warning: Failed to download pandoc diagram filter." \
        git clone --depth 1 https://github.com/pandoc-ext/diagram.git "$FILTER_DIR"
fi