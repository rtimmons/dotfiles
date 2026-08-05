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
