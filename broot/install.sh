#!/usr/bin/env bash

mkdir -p "$HOME/Library/Preferences/org.dystroy.broot/"

pushd "$(dirname "$0")" || exit 1 >/dev/null
  mydir=$(pwd -P)
popd || exit 2 >/dev/null

# test -h file: True if file exists and is a symbolic link.
if [ ! -h "$HOME/Library/Preferences/org.dystroy.broot/conf.toml" ]; then
    ln -s "$mydir/conf.toml" "$HOME/Library/Preferences/org.dystroy.broot/conf.toml"
fi

brew install rust

if ! command -v broot >/dev/null; then
    # 'cargo install' isn't idempotent and 'cargo install -f' does an expensive re-compile
    cargo install broot || true
fi
