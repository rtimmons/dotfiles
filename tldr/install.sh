#!/usr/bin/env bash

set -eou pipefail

brew install --quiet tldr

hash -r
if command -v tldr >/dev/null 2>&1; then
    tldr --update >/dev/null
fi
