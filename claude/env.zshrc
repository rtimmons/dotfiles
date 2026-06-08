#!/usr/bin/env zsh

claude() {
    local dotfiles_claude_dir node_version
    dotfiles_claude_dir="$(dirname "${(%):-%x}")"
    node_version="$(command tr -d '[:space:]' < "$dotfiles_claude_dir/.nvmrc")"
    node_version="${node_version#v}"
    mise exec "node@${node_version}" -- claude "$@"
}
