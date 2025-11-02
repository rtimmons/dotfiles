#!/usr/bin/env bash

mkdir -p "$HOME/Library/Preferences/org.dystroy.broot/"

pushd "$(dirname "$0")" >/dev/null || exit 1
  mydir=$(pwd -P)
popd >/dev/null || exit 2

# test -h file: True if file exists and is a symbolic link.
if [ ! -h "$HOME/Library/Preferences/org.dystroy.broot/conf.toml" ]; then
    ln -s "$mydir/conf.toml" "$HOME/Library/Preferences/org.dystroy.broot/conf.toml"
fi

brew install --quiet rust

if ! command -v broot >/dev/null; then
    # 'cargo install' isn't idempotent and 'cargo install -f' does an expensive re-compile
    cargo install broot || true
fi
