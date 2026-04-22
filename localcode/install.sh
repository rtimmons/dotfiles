#!/usr/bin/env bash
set -euo pipefail

MODEL="${LOCALCODE_MODEL:-qwen3-coder:30b}"
OLLAMA_HOST_VALUE="${OLLAMA_HOST:-127.0.0.1:11434}"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_DIR}/opencode.json"

run_quiet() {
    local message="$1"
    shift

    local log_file
    log_file="$(mktemp -t localcode-install.XXXXXX)"

    if ! "$@" >"$log_file" 2>&1; then
        printf '%s\n' "$message" >&2
        cat "$log_file" >&2
        rm -f "$log_file"
        return 1
    fi

    rm -f "$log_file"
}

if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' "localcode: Homebrew not found. Install Homebrew first." >&2
    exit 1
fi

if ! command -v ollama >/dev/null 2>&1; then
    run_quiet "localcode: failed to install Ollama." brew install --cask --quiet ollama
fi

if ! command -v opencode >/dev/null 2>&1; then
    run_quiet "localcode: failed to install opencode." brew install --quiet anomalyco/tap/opencode
fi

mkdir -p "$OPENCODE_CONFIG_DIR"

tmp_config="$(mktemp -t opencode-config.XXXXXX)"
cleanup() {
    rm -f "$tmp_config"
}
trap cleanup EXIT

cat >"$tmp_config" <<JSON
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "ollama/${MODEL}",
  "provider": {
    "ollama": {
      "options": {
        "baseURL": "http://${OLLAMA_HOST_VALUE}/v1"
      },
      "models": {
        "${MODEL}": {}
      }
    }
  }
}
JSON

if [[ ! -f "$OPENCODE_CONFIG_FILE" ]] || ! cmp -s "$tmp_config" "$OPENCODE_CONFIG_FILE"; then
    mv "$tmp_config" "$OPENCODE_CONFIG_FILE"
fi
