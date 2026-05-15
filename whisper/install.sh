#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

brew install --quiet ffmpeg

VENV="./venv"

if [[ ! -x "$VENV/bin/whisper" ]]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install -q --upgrade pip
    "$VENV/bin/pip" install -q openai-whisper
fi
