#!/usr/bin/env bash

set -eou pipefail

brew install tldr

reload!
tldr --update
