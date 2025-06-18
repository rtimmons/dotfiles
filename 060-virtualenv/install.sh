#!/usr/bin/env bash

set -eou pipefail

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv init --path)"
fi

pyenv rehash
PIP_REQUIRE_VIRTUALENV=false pip install virtualenv
pyenv rehash # not sure if this is needed ¯\_(ツ)_/¯

if [ ! -e "$HOME/venv" ]; then
    python3 -mvenv venv
fi
