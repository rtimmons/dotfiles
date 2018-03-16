#!/usr/bin/env bash
# TODO: not sure if I wanna invest more fully into "doom emacs" yet...here for posterity

# https://github.com/hlissner/doom-emacs
brew install gnu-tar
brew tap d12frosted/emacs-plus
brew install emacs-plus
brew services start d12frosted/emacs-plus/emacs-plus

# https://github.com/hlissner/doom-emacs/tree/master/modules/lang/cc
brew install rdm
# TODO: clone ~/.emacs.d, copy init, and `make`
