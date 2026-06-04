#!/usr/bin/env bash
set -euo pipefail

skills_dir="$1"
humanizer_dir="$skills_dir/humanizer"
if [[ -d "$humanizer_dir/.git" ]]; then
    git -C "$humanizer_dir" pull --ff-only --quiet
else
    git clone --quiet https://github.com/blader/humanizer.git "$humanizer_dir"
fi
