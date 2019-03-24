#!/usr/bin/env zsh

if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then

pushd "$(dirname "$0")" >/dev/null

py_home="$(pyenv prefix)"
    util="$py_home/bin/powerline-daemon"
        if [ -e "$util" ]; then
            POWERLINE_CONFIG_PATHS=(
                "$ZSH/powerline/config"
            )
            # start daemon
            "$py_home"/bin/powerline-daemon -q
            # run it up
            source "$py_home"/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh
        fi
    unset util
unset py_home


# powerlevel10k
if [ -e "$ZSH/powerline/powerlevel10k" ]; then
    # local config file
    source "$ZSH/powerline/powerlevel-config.zsh"
    # load 'er up!
    source "$ZSH/powerline/powerlevel10k/powerlevel10k.zsh-theme"
fi

popd >/dev/null

fi
