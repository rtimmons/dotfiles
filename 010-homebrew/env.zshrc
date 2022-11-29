#!/usr/bin/env bash

add_to_path "${BREW_PREFIX}/sbin"

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
if type brew &>/dev/null; then
  FPATH="${BREW_PREFIX}/share/zsh/site-functions:$FPATH"
fi


export HOMEBREW_NO_AUTO_UPDATE=1
