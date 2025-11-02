#!/usr/bin/env bash

set -eou pipefail

brew install --quiet pipx

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
