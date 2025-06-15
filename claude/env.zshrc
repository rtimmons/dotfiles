#!/usr/bin/env zsh

claude() {
    local dotfiles_claude_dir
    
    # Find the dotfiles claude directory more robustly
    dotfiles_claude_dir="$(dirname "${(%):-%x}")"
    
    # Use nvm-exec with NODE_VERSION to ensure we use the right Node version
    # without having to change directories
    NODE_VERSION="$(cat "$dotfiles_claude_dir/.nvmrc")" "$(brew --prefix nvm)/nvm-exec" claude "$@"
}
