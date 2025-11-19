#!/usr/bin/env bash

# Utility helpers for install scripts. Source this file from within an install
# script to access shared logic.

pushd_silent() {
    if [[ $# -eq 0 ]]; then
        return 0
    fi
    pushd "$@" >/dev/null || return $?
}

popd_silent() {
    popd >/dev/null || return $?
}

brew_install() {
    if [[ $# -eq 0 ]]; then
        return 0
    fi
    brew install --quiet "$@"
}

ensure_desired_node() {
    local target_dir="${1:-.}"
    local nvmrc_path="$target_dir/.nvmrc"

    if [[ ! -f "$nvmrc_path" ]]; then
        return 0
    fi

    local node_version
    node_version="$(tr -d '[:space:]' < "$nvmrc_path")"
    if [[ -z "$node_version" ]]; then
        return 0
    fi

    if [[ "$(nvm version "$node_version" 2>/dev/null)" == "N/A" ]]; then
        printf 'Installing Node %s (from %s)\n' \
            "$node_version" "$nvmrc_path"
        nvm install "$node_version"
    fi
}

add_to_path() {
    local candidate="${1:-}"
    if [[ -z "$candidate" ]]; then
        return 0
    fi

    case ":${PATH-}:" in
        *":$candidate:"*) ;;
        *)
            if [[ -n "${PATH-}" ]]; then
                PATH="$candidate:$PATH"
            else
                PATH="$candidate"
            fi
            export PATH
            ;;
    esac
}