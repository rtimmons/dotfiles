#!/usr/bin/env zsh

codex() {
    local dotfiles_codex_dir
    local node_version

    dotfiles_codex_dir="$(dirname "${(%):-%x}")"
    node_version="$(command tr -d '[:space:]' < "$dotfiles_codex_dir/.nvmrc")"

    NODE_VERSION="$node_version" "$(brew --prefix nvm)/libexec/nvm-exec" codex "$@"
}
