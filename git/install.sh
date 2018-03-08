#!/usr/bin/env bash
set -eou pipefail

pushd "$HOME" >/dev/null
    if [ ! -e ".gitconfig-private" ]; then
        touch ".gitconfig-private"
    fi
popd >/dev/null
