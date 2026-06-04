#!/usr/bin/env bash

set -euo pipefail

if ! command -v opencode >/dev/null 2>&1; then
    brew trust --formula anomalyco/tap/opencode
    brew install --quiet anomalyco/tap/opencode
fi
