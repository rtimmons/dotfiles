#!/usr/bin/env bash

set -euo pipefail

if command -v brew >/dev/null 2>&1; then
    brew install --quiet gh
fi
