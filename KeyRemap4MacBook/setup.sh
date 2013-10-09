#!/usr/bin/env bash

if [ -z "$ZSH" ]; then
    echo "Need \$ZSH location of dotfiles project.  Die."
    exit 1
fi

dir="$HOME/Library/Application Support/KeyRemap4MacBook"
mkdir -p "$dir"
cd "$dir"

if [ -f "private.xml" ]; then
    rm "private.xml"
fi

ln -s "$ZSH/KeyRemap4MacBook/private.xml" "./private.xml"


