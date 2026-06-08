#!/usr/bin/env zsh

auggie() {
    local dotfiles_auggie_dir node_version
    dotfiles_auggie_dir="$(dirname "${(%):-%x}")"
    node_version="$(command tr -d '[:space:]' < "$dotfiles_auggie_dir/.nvmrc")"
    mise exec "node@${node_version}" -- auggie "$@"
}
