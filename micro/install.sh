#!/usr/bin/env bash

set -euo pipefail

if [[ -e "./micro" ]]; then
    exit 0
fi
curl https://getmic.ro | bash
