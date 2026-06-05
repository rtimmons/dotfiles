#!/usr/bin/env bash

set -euo pipefail

brew trust --formula anomalyco/tap/opencode
if ! command -v opencode >/dev/null 2>&1; then
    brew install --quiet anomalyco/tap/opencode
fi
