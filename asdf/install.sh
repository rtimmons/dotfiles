#!/usr/bin/env bash

set -eou pipefail

brew install asdf
source "$(brew --prefix)/opt/asdf/libexec/asdf.sh"

rehash

