#!/usr/bin/env bash

set -euo pipefail

if ! command -v go >/dev/null 2>&1; then
    echo "tailcat: Go is required." >&2
    exit 1
fi

log_file="$(mktemp -t tailcat-install.XXXXXX)"
trap 'rm -f "$log_file"' EXIT

if ! go install github.com/tailscale/tailcat/cmd/tailcat@latest >"$log_file" 2>&1; then
    cat "$log_file" >&2
    exit 1
fi
