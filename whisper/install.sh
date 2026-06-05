#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

brew install --quiet ffmpeg jq fswatch

VENV="./venv"

if ! "$VENV/bin/python" -c 'import mlx_whisper, whisperx' >/dev/null 2>&1; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install -q --upgrade pip
    "$VENV/bin/pip" install -q mlx-whisper whisperx
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