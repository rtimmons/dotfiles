#!/usr/bin/env bash
set -eou pipefail

if [[ ! -e "$HOME/.scons" ]]; then
    mkdir "$HOME/.scons"
fi

rm -f "$HOME/.scons/site_scons"

ln -s "$ZSH/mongo-scons/site_scons" "$HOME/.scons/site_scons"
