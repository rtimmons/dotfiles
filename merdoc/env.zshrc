#!/usr/bin/env bash
add_to_path "$ZSH/merdoc/bin"

# Add merdoc directory to fpath for zsh completion
fpath=("$ZSH/merdoc" $fpath)
