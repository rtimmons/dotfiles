#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

brew install --quiet ffmpeg jq fswatch

VENV="./venv"

# True if the given python links against OpenSSL rather than the macOS system
# LibreSSL build. urllib3 v2 warns on every import under LibreSSL.
is_openssl_python() {
    "$1" -c 'import ssl,sys; sys.exit(0 if ssl.OPENSSL_VERSION.startswith("OpenSSL") else 1)' \
        >/dev/null 2>&1
}

# Pick a python3 built against OpenSSL. Prefer pyenv/homebrew over the system
# CommandLineTools python (which links LibreSSL).
pick_python() {
    local candidate
    for candidate in \
        "$(pyenv which python3 2>/dev/null || true)" \
        python3 python3.13 python3.12 python3.11 python3.10 \
        /opt/homebrew/bin/python3; do
        [[ -n "$candidate" ]] || continue
        command -v "$candidate" >/dev/null 2>&1 || continue
        if is_openssl_python "$candidate"; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

venv_ok() {
    [[ -x "$VENV/bin/python" ]] \
        && is_openssl_python "$VENV/bin/python" \
        && "$VENV/bin/python" -c 'import mlx_whisper, whisperx' >/dev/null 2>&1
}

if ! venv_ok; then
    PYTHON_BIN="$(pick_python)" || {
        echo "Error: no OpenSSL-based python3 found." >&2
        echo "Install one, e.g. 'brew install python' or 'pyenv install 3.12'." >&2
        exit 1
    }
    # Preserve model markers across a rebuild so the daemon keeps working.
    TOKEN_BAK="$(cat "$VENV/.hf_token" 2>/dev/null || true)"
    MODELS_BAK=""
    [[ -f "$VENV/.models_installed" ]] && MODELS_BAK=1
    rm -rf "$VENV"
    "$PYTHON_BIN" -m venv "$VENV"
    "$VENV/bin/pip" install -q --upgrade pip
    "$VENV/bin/pip" install -q mlx-whisper whisperx
    if [[ -n "$TOKEN_BAK" ]]; then
        printf '%s' "$TOKEN_BAK" > "$VENV/.hf_token"
        chmod 600 "$VENV/.hf_token"
    fi
    [[ -n "$MODELS_BAK" ]] && touch "$VENV/.models_installed"
fi

if [[ -n "${HUGGING_FACE_TOKEN:-}" ]]; then
    ./install_models.sh
fi

mkdir -p logs
chmod +x bin/whisper-watch bin/whisper-watch-daemon tests/run-tests.sh

DOTFILES_DIR="$(cd .. && pwd)"
CONFIG="$HOME/.whisper-watch-config.json"

if [[ ! -f "$CONFIG" ]]; then
    cat > "$CONFIG" << 'EOF'
{
  "drop_folder": "/Users/rtimmons/My Drive/Voice Memos",
  "obsidian_vault_root": "/Users/rtimmons/Library/CloudStorage/GoogleDrive-ryan.timmons@mongodb.com/My Drive/MongoNotes",
  "obsidian_meetings_subdir": "Meetings",
  "obsidian_summaries_subdir": "AI/Summaries",
  "cleanup": "leave",
  "log_level": "info",
  "log_retention_days": 7,
  "error_log_retention_days": 30
}
EOF
    echo "Created whisper-watch config: $CONFIG"
fi

PLIST_LABEL="com.rtimmons.whisper-watch"
PLIST_DST="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"
mkdir -p "$HOME/Library/LaunchAgents"

sed "s|DOTFILES_DIR|$DOTFILES_DIR|g" \
    com.rtimmons.whisper-watch.plist.template > "$PLIST_DST"

launchctl unload "$PLIST_DST" 2>/dev/null || true
launchctl load -w "$PLIST_DST"

# Grant Claude write access to the Obsidian vault so eval-transcript can save
# summaries. --dangerously-skip-permissions bypasses interactive prompts but
# NOT the permissions.allow list — the vault must be explicitly listed there.
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
VAULT_ROOT="$(jq -r '.obsidian_vault_root' "$CONFIG")"
if [[ -f "$CLAUDE_SETTINGS" ]] && [[ -n "$VAULT_ROOT" ]]; then
    UPDATED="$(jq \
        --arg vault "$VAULT_ROOT" \
        '.permissions.additionalDirectories |= (. + [$vault] | unique) |
         .permissions.allow |= (. + [
             "Write(\($vault)/**)",
             "Edit(\($vault)/**)"
         ] | unique)' \
        "$CLAUDE_SETTINGS")"
    echo "$UPDATED" > "$CLAUDE_SETTINGS"
    echo "Added vault to Claude permissions: $VAULT_ROOT"
fi