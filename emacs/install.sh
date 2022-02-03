#!/usr/bin/env bash

brew install --cask emacs

if [ ! -e "$ZSH/emacs/prelude" ]; then
    git clone git://github.com/bbatsov/prelude.git "$ZSH/emacs/prelude"
fi
rm -f "$HOME/.emacs.d"
ln -s "$ZSH/emacs/prelude" "$HOME/.emacs.d"

pushd "$ZSH/emacs/prelude"
    rm -rf personal
    git pull
    ln -s "$ZSH/emacs/prelude-personal" personal
popd
