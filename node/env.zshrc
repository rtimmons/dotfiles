#!/usr/bin/env zsh

# Ensure globally installed npm CLIs (codex, claude, etc.) are reachable
# without eagerly loading nvm. We read the .nvmrc files managed in this repo,
# derive the corresponding ~/.nvm/versions/.../bin directories, and add them to PATH.
# Remember to run `rake install` (which invokes node/install.sh) after adding a
# new tool/.nvmrc so the node version is installed before this PATH logic executes.
for nvmrc in "$ZSH"/*/.nvmrc(.N); do
    node_version="$(command tr -d '[:space:]' < "$nvmrc")"
    [[ -n "$node_version" ]] || continue
    node_bin="$HOME/.nvm/versions/node/${node_version}/bin"
    add_to_path "$node_bin"
done
