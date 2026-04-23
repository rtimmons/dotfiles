#!/usr/bin/env zsh

auggie() {
    local dotfiles_auggie_dir
    local node_version

    dotfiles_auggie_dir="$(dirname "${(%):-%x}")"
    node_version="$(command tr -d '[:space:]' < "$dotfiles_auggie_dir/.nvmrc")"

    NODE_VERSION="$node_version" "$(brew --prefix nvm)/libexec/nvm-exec" auggie "$@"
}
