#!/usr/bin/env bash

brew install --cask --quiet emacs

if [ ! -e "$ZSH/emacs/prelude" ]; then
    git clone --quiet git://github.com/bbatsov/prelude.git "$ZSH/emacs/prelude"
fi
rm -f "$HOME/.emacs.d"
ln -s "$ZSH/emacs/prelude" "$HOME/.emacs.d"

pushd "$ZSH/emacs/prelude" >/dev/null || exit 1
    rm -rf personal
    git pull --ff-only --quiet
    ln -s "$ZSH/emacs/prelude-personal" personal
popd >/dev/null || exit 2
