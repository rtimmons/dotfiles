#!/usr/bin/env bash

if [ -n "$BREW_PREFIX" ]; then
  add_to_path "${BREW_PREFIX}/bin"
  add_to_path "${BREW_PREFIX}/sbin"
fi

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
if command -v brew >/dev/null 2>&1; then
  FPATH="${BREW_PREFIX}/share/zsh/site-functions:$FPATH"
fi

export HOMEBREW_NO_AUTO_UPDATE=1