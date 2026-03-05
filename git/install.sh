#!/usr/bin/env bash
set -euo pipefail

pushd "$HOME" >/dev/null
    if [ ! -e ".gitconfig-private" ]; then
        touch ".gitconfig-private"
    fi
popd >/dev/null
