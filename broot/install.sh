#!/usr/bin/env bash

mkdir -p "$HOME/Library/Preferences/org.dystroy.broot/"

pushd "$(dirname "$0")" >/dev/null
  mydir=$(pwd -P)
popd >/dev/null

ln -s "$mydir/conf.toml" "$HOME/Library/Preferences/org.dystroy.broot/conf.toml"

brew install rust
# 'cargo install' isn't idempotent and 'cargo install -f' does an expensive re-compile
cargo install broot || true
