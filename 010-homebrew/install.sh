#!/usr/bin/env bash

set -euo pipefail

if ! brew trust --help >/dev/null 2>&1; then
    exit 0
fi

# Keep third-party trust limited to the formulae this repo installs.
brew trust --formula \
    anomalyco/tap/opencode \
    heroku/brew/heroku \
    >/dev/null

# Protect the working llama.cpp HEAD long enough for localcode/install.sh to
# replace it with the stable release after the routine global upgrade.
if brew list --versions llama.cpp 2>/dev/null \
    | grep -Eq '(^|[[:space:]])HEAD-' \
    && ! brew list --pinned | grep -Fxq 'llama.cpp'; then
    brew pin llama.cpp >/dev/null
fi
