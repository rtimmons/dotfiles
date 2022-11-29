#!/usr/bin/env bash

set -eou pipefail

brew install asdf
source "${BREW_PREFIX}/opt/asdf/libexec/asdf.sh"

rehash

