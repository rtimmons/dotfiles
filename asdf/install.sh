#!/usr/bin/env bash

set -eou pipefail

brew install asdf
# shellcheck source=/dev/null
source "${BREW_PREFIX}/opt/asdf/libexec/asdf.sh"

rehash

