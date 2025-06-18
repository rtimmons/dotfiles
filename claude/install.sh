#!/usr/bin/env bash
set -eou pipefail

cd "$(dirname "$0")" || exit 1

source "$(brew --prefix nvm)/libexec/nvm.sh"
nvm install

"$(brew --prefix nvm)/nvm-exec" npm install -g @anthropic-ai/claude-code

command -v claude
