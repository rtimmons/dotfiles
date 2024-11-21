#!/usr/bin/env bash

# https://shyr.io/blog/sync-iterm2-configs
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/Projects/dotfiles/iterm/Preferences"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

if [ ! -f ~/.iterm2_shell_integration.zsh ]; then
    curl -L https://iterm2.com/shell_integration/zsh \
        -o ~/.iterm2_shell_integration.zsh
fi
