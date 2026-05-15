#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

if [[ -z "${HUGGING_FACE_TOKEN:-}" ]]; then
    cat >&2 <<'EOF'
Error: HUGGING_FACE_TOKEN environment variable is required.

To enable speaker diarization:
1. Create a HuggingFace account at https://huggingface.co
2. Get a read token at https://huggingface.co/settings/tokens
3. Log in and click "Agree and access repository" at:
   https://huggingface.co/pyannote/speaker-diarization-community-1
4. Export HUGGING_FACE_TOKEN=<token> and re-run
EOF
    exit 1
fi

VENV="./venv"

if [[ ! -x "$VENV/bin/python" ]]; then
    echo "Error: venv not found. Run install.sh first." >&2
    exit 1
fi

HF_TOKEN="$HUGGING_FACE_TOKEN" "$VENV/bin/hf" download \
    --quiet pyannote/speaker-diarization-community-1 > /dev/null

printf '%s' "$HUGGING_FACE_TOKEN" > ./venv/.hf_token
chmod 600 ./venv/.hf_token
touch ./venv/.models_installed
