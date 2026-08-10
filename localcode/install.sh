#!/usr/bin/env bash
set -euo pipefail

MODEL="${LOCALCODE_MODEL:-qwen3-coder:30b}"
MUSE_MODEL="muse-glimmer-30b"
OLLAMA_MODEL="${LOCALCODE_OLLAMA_MODEL:-qwen3-coder:30b}"
OLLAMA_HOST_VALUE="${OLLAMA_HOST:-127.0.0.1:11434}"
LLAMA_HOST_VALUE="${LOCALCODE_LLAMA_HOST:-127.0.0.1}"
LLAMA_PORT_VALUE="${LOCALCODE_LLAMA_PORT:-8080}"
CONTEXT_LENGTH="${LOCALCODE_CONTEXT_LENGTH:-65536}"
OUTPUT_LENGTH="${LOCALCODE_OUTPUT_LENGTH:-32768}"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_DIR}/opencode.json"

if [[ "$MODEL" == "$MUSE_MODEL" ]]; then
    DEFAULT_MODEL="llamacpp/${MUSE_MODEL}"
else
    DEFAULT_MODEL="ollama/${MODEL}"
    OLLAMA_MODEL="$MODEL"
fi

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

BREW_PREFIX_VALUE="$(brew --prefix)"
LLAMA_SERVER="${BREW_PREFIX_VALUE}/bin/llama-server"

llama_cpp_supports_muse() {
    local candidate
    local llama_cpp_prefix

    [[ -x "$LLAMA_SERVER" ]] || return 1
    llama_cpp_prefix="$(brew --prefix llama.cpp 2>/dev/null)" || return 1
    for candidate in \
        "${llama_cpp_prefix}/lib/libllama.dylib" \
        "${llama_cpp_prefix}/lib/libllama.so"; do
        [[ -r "$candidate" ]] || continue
        if LC_ALL=C grep -aFq 'muse-glimmer' "$candidate"; then
            return 0
        fi
    done
    return 1
}

install_llama_cpp() {
    if brew list --versions llama.cpp >/dev/null 2>&1; then
        brew reinstall --HEAD llama.cpp
    else
        brew install --HEAD llama.cpp
    fi
}

if ! command -v ollama >/dev/null 2>&1; then
    run_quiet "localcode: failed to install Ollama." brew install --cask --quiet ollama
fi

if ! command -v opencode >/dev/null 2>&1; then
    run_quiet "localcode: failed to install opencode." brew install --quiet anomalyco/tap/opencode
fi

if ! command -v jq >/dev/null 2>&1; then
    run_quiet "localcode: failed to install jq." brew install jq
fi

if ! llama_cpp_supports_muse; then
    run_quiet "localcode: failed to install a Muse-compatible llama.cpp." install_llama_cpp
fi

if ! llama_cpp_supports_muse; then
    printf '%s\n' "localcode: installed llama.cpp does not support Muse Glimmer." >&2
    exit 1
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
  "model": "${DEFAULT_MODEL}",
  "provider": {
    "ollama": {
      "options": {
        "baseURL": "http://${OLLAMA_HOST_VALUE}/v1"
      },
      "models": {
        "${OLLAMA_MODEL}": {}
      }
    },
    "llamacpp": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "llama.cpp (local)",
      "options": {
        "baseURL": "http://${LLAMA_HOST_VALUE}:${LLAMA_PORT_VALUE}/v1"
      },
      "models": {
        "${MUSE_MODEL}": {
          "name": "Muse Glimmer 30B",
          "limit": {
            "context": ${CONTEXT_LENGTH},
            "output": ${OUTPUT_LENGTH}
          }
        }
      }
    }
  }
}
JSON

if [[ ! -f "$OPENCODE_CONFIG_FILE" ]] || ! cmp -s "$tmp_config" "$OPENCODE_CONFIG_FILE"; then
    mv "$tmp_config" "$OPENCODE_CONFIG_FILE"
fi
