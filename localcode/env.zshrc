export LOCALCODE_MODEL="${LOCALCODE_MODEL:-qwen3-coder:30b}"
export LOCALCODE_FRONTEND="${LOCALCODE_FRONTEND:-opencode}"
export LOCALCODE_CONTEXT_LENGTH="${LOCALCODE_CONTEXT_LENGTH:-65536}"
export LOCALCODE_OUTPUT_LENGTH="${LOCALCODE_OUTPUT_LENGTH:-32768}"
export LOCALCODE_LLAMA_HOST="${LOCALCODE_LLAMA_HOST:-127.0.0.1}"
export LOCALCODE_LLAMA_PORT="${LOCALCODE_LLAMA_PORT:-8080}"
export LOCALCODE_DATA_DIR="${LOCALCODE_DATA_DIR:-${HOME}/.local/share/localcode}"
export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export OLLAMA_CONTEXT_LENGTH="${OLLAMA_CONTEXT_LENGTH:-${LOCALCODE_CONTEXT_LENGTH}}"

if [[ -z "${LOCALCODE_LLAMA_SERVER:-}" ]]; then
    localcode_brew_prefix="$(brew --prefix 2>/dev/null)" || localcode_brew_prefix=""
    if [[ -n "$localcode_brew_prefix" ]]; then
        LOCALCODE_LLAMA_SERVER="${localcode_brew_prefix}/bin/llama-server"
    fi
fi
export LOCALCODE_LLAMA_SERVER
unset localcode_brew_prefix

alias oc='opencode'

_localcode_print_help() {
    printf '%s\n' \
        'Usage: localcode [options] [--] [frontend arguments...]' \
        '' \
        'Run a local coding model with OpenCode or Oh My Pi.' \
        '' \
        'Options:' \
        '  -m, --model MODEL          Model to run' \
        '  -f, --frontend FRONTEND    Frontend: opencode or omp (oh-my-pi)' \
        '  -h, --help                 Show this help' \
        '' \
        'Defaults may be set with LOCALCODE_MODEL and LOCALCODE_FRONTEND.' \
        'Arguments after -- are passed directly to the selected frontend.'
}

_localcode_run_frontend() {
    emulate -L zsh
    setopt pipefail

    local frontend="$1"
    local provider="$2"
    local model="$3"
    shift 3

    local selector
    case "$frontend" in
        opencode)
            if ! command -v opencode >/dev/null 2>&1; then
                printf '%s\n' "localcode: opencode not found. Run just install." >&2
                return 1
            fi
            selector="${provider}/${model}"
            opencode "$@" --model "$selector"
            ;;
        omp)
            if ! command -v omp >/dev/null 2>&1; then
                printf '%s\n' "localcode: omp not found. Run just install." >&2
                return 1
            fi
            if [[ "$provider" == llamacpp ]]; then
                provider='llama.cpp'
            fi
            selector="${provider}/${model}"
            LLAMA_CPP_BASE_URL="http://${LOCALCODE_LLAMA_HOST}:${LOCALCODE_LLAMA_PORT}" \
                omp --model "$selector" "$@"
            ;;
    esac
}

_localcode_download() {
    emulate -L zsh
    setopt pipefail

    local expected_size="$1"
    local label="$2"
    local target="$3"
    local url="$4"
    local actual_size
    local partial="${target}.partial"

    if [[ -f "$target" ]]; then
        actual_size="$(stat -f '%z' "$target")" || return
        if [[ "$actual_size" == "$expected_size" ]]; then
            return 0
        fi

        printf '%s\n' \
            "localcode: ${label} is ${actual_size} bytes; expected ${expected_size}: ${target}" >&2
        rm -f "$target" || return
    fi

    printf '%s\n' "localcode: downloading ${label}..." >&2
    if ! curl --fail --location --retry 3 --continue-at - \
        --output "$partial" "$url"; then
        printf '%s\n' "localcode: failed to download ${label}." >&2
        rm -f "$partial"
        return 1
    fi

    actual_size="$(stat -f '%z' "$partial")" || return
    if [[ "$actual_size" != "$expected_size" ]]; then
        printf '%s\n' \
            "localcode: ${label} download is ${actual_size} bytes; expected ${expected_size}: ${partial}" >&2
        rm -f "$partial"
        return 1
    fi

    mv "$partial" "$target"
}

_localcode_run_ollama() {
    emulate -L zsh
    setopt pipefail

    local frontend="$1"
    local model="$2"
    shift 2

    local host="${OLLAMA_HOST}"

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
        ollama pull "$model" || return
    fi

    _localcode_run_frontend "$frontend" ollama "$model" "$@"
}

_localcode_muse_server_ready() {
    emulate -L zsh
    setopt pipefail

    local base_url="$1"
    local model="$2"
    curl -fsS "${base_url}/v1/models" 2>/dev/null \
        | jq -e --arg model "$model" 'any(.data[]?; .id == $model)' \
            >/dev/null 2>&1
}

_localcode_stop_server() {
    emulate -L zsh
    setopt pipefail

    local server_pid="$1"
    local log_file="$2"
    local attempt

    if kill -0 "$server_pid" 2>/dev/null; then
        kill "$server_pid" 2>/dev/null || true
        for attempt in {1..20}; do
            kill -0 "$server_pid" 2>/dev/null || break
            sleep 0.1
        done
        if kill -0 "$server_pid" 2>/dev/null; then
            kill -KILL "$server_pid" 2>/dev/null || true
        fi
        wait "$server_pid" 2>/dev/null || true
    fi

    rm -f "$log_file"
}

_localcode_run_muse() {
    emulate -L zsh
    setopt pipefail

    local frontend="$1"
    local model="$2"
    shift 2

    local base_url="http://${LOCALCODE_LLAMA_HOST}:${LOCALCODE_LLAMA_PORT}"
    local model_dir="${LOCALCODE_DATA_DIR}/models/${model}"
    local model_file="${model_dir}/muse-glimmer-30B-kquant-17gb.gguf"
    local draft_file="${model_dir}/dflash-kquant.gguf"
    local server_pid=""
    local log_file=""
    local ready=0
    local attempt
    local exit_status

    if [[ ! -x "$LOCALCODE_LLAMA_SERVER" ]]; then
        printf '%s\n' "localcode: llama-server not found. Run just install." >&2
        return 1
    fi

    mkdir -p "$model_dir" || return
    _localcode_download \
        16756681056 \
        "Muse Glimmer 30B (17 GB)" \
        "$model_file" \
        "https://huggingface.co/meta-models/Muse-Glimmer-30B-GGUF/resolve/main/muse-glimmer-30B-kquant-17gb.gguf" \
        || return
    _localcode_download \
        1631205312 \
        "Muse Glimmer DFlash drafter" \
        "$draft_file" \
        "https://huggingface.co/meta-models/Muse-Glimmer-30B-GGUF/resolve/main/dflash-kquant.gguf" \
        || return

    if _localcode_muse_server_ready "$base_url" "$model"; then
        _localcode_run_frontend "$frontend" llamacpp "$model" "$@"
        return
    fi

    if curl -fsS "${base_url}/health" >/dev/null 2>&1; then
        printf '%s\n' "localcode: ${base_url} is already serving a different model." >&2
        return 1
    fi

    log_file="$(mktemp -t localcode-llama.XXXXXX)" || return
    "$LOCALCODE_LLAMA_SERVER" \
        --model "$model_file" \
        --spec-draft-model "$draft_file" \
        --spec-type draft-dflash \
        --spec-draft-n-max 15 \
        --ctx-size "${LOCALCODE_CONTEXT_LENGTH}" \
        --gpu-layers all \
        --flash-attn on \
        --jinja \
        --reasoning on \
        --reasoning-preserve \
        --temp 1.0 \
        --top-p 0.95 \
        --top-k 64 \
        --alias "$model" \
        --host "${LOCALCODE_LLAMA_HOST}" \
        --port "${LOCALCODE_LLAMA_PORT}" \
        >"$log_file" 2>&1 &
    server_pid="$!"

    {
        for attempt in {1..120}; do
            if _localcode_muse_server_ready "$base_url" "$model"; then
                ready=1
                break
            fi
            if ! kill -0 "$server_pid" 2>/dev/null; then
                break
            fi
            sleep 1
        done

        if [[ "$ready" -ne 1 ]]; then
            printf '%s\n' "localcode: llama-server failed to start." >&2
            cat "$log_file" >&2
            return 1
        fi

        if _localcode_run_frontend "$frontend" llamacpp "$model" "$@"; then
            exit_status=0
        else
            exit_status="$?"
        fi
    } always {
        _localcode_stop_server "$server_pid" "$log_file"
    }

    return "$exit_status"
}

localcode() {
    emulate -L zsh
    setopt pipefail

    local model="${LOCALCODE_MODEL}"
    local frontend="${LOCALCODE_FRONTEND}"
    local -a frontend_args

    while (( $# )); do
        case "$1" in
            -m|--model)
                if (( $# < 2 )) || [[ -z "$2" ]]; then
                    printf '%s\n' "localcode: $1 requires a model." >&2
                    return 2
                fi
                model="$2"
                shift 2
                ;;
            --model=*)
                model="${1#*=}"
                if [[ -z "$model" ]]; then
                    printf '%s\n' "localcode: --model requires a model." >&2
                    return 2
                fi
                shift
                ;;
            -f|--frontend)
                if (( $# < 2 )) || [[ -z "$2" ]]; then
                    printf '%s\n' "localcode: $1 requires a frontend." >&2
                    return 2
                fi
                frontend="$2"
                shift 2
                ;;
            --frontend=*)
                frontend="${1#*=}"
                if [[ -z "$frontend" ]]; then
                    printf '%s\n' "localcode: --frontend requires a frontend." >&2
                    return 2
                fi
                shift
                ;;
            -h|--help)
                _localcode_print_help
                return
                ;;
            --)
                shift
                frontend_args+=("$@")
                break
                ;;
            *)
                frontend_args+=("$1")
                shift
                ;;
        esac
    done

    case "$frontend" in
        oh-my-pi)
            frontend=omp
            ;;
        opencode|omp)
            ;;
        *)
            printf '%s\n' \
                "localcode: unsupported frontend '${frontend}'; use opencode or omp (oh-my-pi)." >&2
            return 2
            ;;
    esac

    case "$model" in
        muse-glimmer-30b)
            _localcode_run_muse "$frontend" "$model" "${frontend_args[@]}"
            ;;
        *)
            _localcode_run_ollama "$frontend" "$model" "${frontend_args[@]}"
            ;;
    esac
}
