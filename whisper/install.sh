#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

brew install --quiet ffmpeg

VENV="./venv"

if ! "$VENV/bin/python" -c 'import mlx_whisper, whisperx' >/dev/null 2>&1; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install -q --upgrade pip
    "$VENV/bin/pip" install -q mlx-whisper whisperx
fi

if [[ -n "${HUGGING_FACE_TOKEN:-}" ]]; then
    ./install_models.sh
fi
