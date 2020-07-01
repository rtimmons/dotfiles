#!/usr/bin/env bash

# add_to_path /usr/local/bin
add_to_path /usr/local/sbin

# Homebrew seems to like to put completions here:
if [[ -d "/usr/local/share/zsh/site-functions" && $(ls -A "/usr/local/share/zsh/site-functions") ]]; then
    fpath=($fpath /usr/local/share/zsh/site-functions)
    autoload -U /usr/local/share/zsh/site-functions/*(:t) 2>/dev/null
fi

export HOMEBREW_NO_AUTO_UPDATE=1
