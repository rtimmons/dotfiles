#!/usr/bin/env bash

easy_install pip

brew install pyenv
brew install readline

# -s means skip if already done - make the thing idempotent
pyenv install -s
