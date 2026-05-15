#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

brew install --quiet ffmpeg

VENV="./venv"

if [[ ! -x "$VENV/bin/whisperx" ]]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install -q --upgrade pip
    "$VENV/bin/pip" install -q whisperx
fi

if [[ -n "${HUGGING_FACE_TOKEN:-}" ]]; then
    ./install_models.sh
fi
