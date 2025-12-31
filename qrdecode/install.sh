#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

log_file="$(mktemp -t qrdecode-install.XXXXXX)"
cleanup() {
    rm -f "$log_file"
}
trap cleanup EXIT

if ! brew install --quiet zbar >"$log_file" 2>&1; then
    cat "$log_file" >&2
    exit 1
fi