#!/usr/bin/env bash

brew install pyenv
brew install readline

# -s means skip if already done - make the thing idempotent
pyenv install -s
