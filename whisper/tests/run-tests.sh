#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/../venv/bin/python" -m unittest discover \
    --start-directory "$SCRIPT_DIR" \
    --pattern "test_*.py" \
    --verbose \
    "$@"