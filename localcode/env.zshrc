export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export OLLAMA_CONTEXT_LENGTH="${OLLAMA_CONTEXT_LENGTH:-65536}"
export LOCALCODE_MODEL="${LOCALCODE_MODEL:-qwen3-coder:30b}"

alias oc='opencode'

localcode() {
    emulate -L zsh
    setopt errexit nounset pipefail

    local host="${OLLAMA_HOST}"
    local model="${LOCALCODE_MODEL}"

    if ! command -v opencode >/dev/null 2>&1; then
        printf '%s\n' "localcode: opencode not found. Run just install." >&2
        return 1
    fi

    if ! command -v ollama >/dev/null 2>&1; then
        printf '%s\n' "localcode: ollama not found. Run just install." >&2
        return 1
    fi

    if ! curl -fsS "http://${host}/api/tags" >/dev/null 2>&1; then
        launchctl setenv OLLAMA_HOST "$host"
        launchctl setenv OLLAMA_CONTEXT_LENGTH "${OLLAMA_CONTEXT_LENGTH}"
        open -a Ollama
        sleep 5
    fi

    if ! ollama show "$model" >/dev/null 2>&1; then
        ollama pull "$model"
    fi

    OPENCODE_MODEL="ollama/${model}" opencode "$@"
}
