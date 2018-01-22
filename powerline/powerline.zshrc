#!/usr/bin/env zsh

cd "$(dirname $0)"


POWERLINE_CONFIG_PATHS=(
    "$ZSH/powerline/config"
)


py_home="$(pyenv prefix)"
    # start daemon
    "$py_home"/bin/powerline-daemon -q
    # run it up
    source "$py_home"/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh
unset py_home


# powerlevel9k
if [ -e "$ZSH/powerline/powerlevel9k" ]; then
    # local config file
    source "./powerlevel-config.zsh"
    # load 'er up!
    source "$ZSH/powerline/powerlevel9k/powerlevel9k.zsh-theme"
fi

