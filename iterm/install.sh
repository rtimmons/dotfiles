#!/usr/bin/env bash

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/Projects/dotfiles/iterm/Preferences"

if [ ! -f ~/.iterm2_shell_integration.zsh ]; then
    curl -L https://iterm2.com/shell_integration/zsh \
        -o ~/.iterm2_shell_integration.zsh
fi
