#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
META="${SCRIPT_DIR}/via-meta.json"
KEYMAP="${SCRIPT_DIR}/vitaly-keymap.json"

keyboard_connected() {
  ioreg -p IOUSB -l 2>/dev/null | grep -qi "keychron"
}

if ! keyboard_connected; then
  exit 0
fi

if ! command -v vitaly &>/dev/null; then
  cargo install vitaly
fi

log="$(mktemp -t vitaly-XXXXXX)"
if vitaly load -m "${META}" -f "${KEYMAP}" >"${log}" 2>&1; then
  rm -f "${log}"
  exit 0
fi

cat "${log}" >&2
rm -f "${log}"
cat >&2 <<EOF
Keychron Q11 detected but vitaly failed to apply the keymap.

Apply manually in 2 steps:
  1. Open https://usevia.app in Chrome
  2. Design → Load saved layout → select keychron-q11/via-keymap.json

EOF
