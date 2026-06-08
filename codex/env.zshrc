#!/usr/bin/env zsh

codex() {
    local dotfiles_codex_dir node_version
    dotfiles_codex_dir="$(dirname "${(%):-%x}")"
    node_version="$(command tr -d '[:space:]' < "$dotfiles_codex_dir/.nvmrc")"
    mise exec "node@${node_version}" -- codex "$@"
}
