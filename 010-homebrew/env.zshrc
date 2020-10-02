#!/usr/bin/env bash

# add_to_path /usr/local/bin
add_to_path /usr/local/sbin

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi


export HOMEBREW_NO_AUTO_UPDATE=1
