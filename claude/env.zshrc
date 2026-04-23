#!/usr/bin/env zsh

claude() {
    local dotfiles_claude_dir
    local node_version
    
    # Find the dotfiles claude directory more robustly
    dotfiles_claude_dir="$(dirname "${(%):-%x}")"
    node_version="$(command tr -d '[:space:]' < "$dotfiles_claude_dir/.nvmrc")"
    
    # Use nvm-exec with NODE_VERSION to ensure we use the right Node version
    # without having to change directories
    NODE_VERSION="$node_version" "$(brew --prefix nvm)/libexec/nvm-exec" claude "$@"
}
