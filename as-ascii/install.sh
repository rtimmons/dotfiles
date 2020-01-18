#!/usr/bin/env bash

set -eou pipefail

cd "$(dirname "$0")"

if [ ! -e ./bin ]; then
    mkdir -p ./bin
fi

if [ ! -e ./bin/as-ascii ]; then
    cc ./as-ascii.c -o ./bin/as-ascii
fi
