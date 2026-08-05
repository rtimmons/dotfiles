#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

if ! command -v podman >/dev/null 2>&1; then
    exit 0
fi

label="com.podman.machine.default"
domain="gui/$(id -u)"
launch_agents_dir="$HOME/Library/LaunchAgents"
plist="$launch_agents_dir/${label}.plist"
podman_bin="$(command -v podman)"

mkdir -p "$launch_agents_dir"
rendered_plist="$(mktemp "${plist}.XXXXXX")"
trap 'rm -f "$rendered_plist"' EXIT

sed "s|PODMAN_BIN|$podman_bin|g" \
    com.podman.machine.default.plist.template > "$rendered_plist"

if ! lint_output="$(plutil -lint "$rendered_plist" 2>&1)"; then
    echo "$lint_output" >&2
    exit 1
fi

if [[ -f "$plist" ]] \
    && cmp -s "$rendered_plist" "$plist" \
    && launchctl print "$domain/$label" >/dev/null 2>&1; then
    exit 0
fi

launchctl bootout "$domain/$label" >/dev/null 2>&1 || true
mv "$rendered_plist" "$plist"
trap - EXIT
launchctl bootstrap "$domain" "$plist" >/dev/null
