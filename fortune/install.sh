#!/usr/bin/env bash

pushd "$(dirname "$0")" >/dev/null || exit 1
    if [ ! -e "obliqueMOTD" ]; then
        git clone --quiet git@github.com:threemachines/obliqueMOTD.git
    fi
popd >/dev/null || exit 1

brew install --quiet fortune
