#!/usr/bin/env bash

easy_install pip
pip install --upgrade pip

brew install pyenv

# dependencies for installing later versions of python through pyenv
brew install readline
brew install zlib
brew install sqlite

# https://github.com/jiansoung/issues-list/issues/13
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/zlib/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/zlib/include"
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/sqlite/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/sqlite/include"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/zlib/lib/pkgconfig"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/sqlite/lib/pkgconfig"

# -s means skip if already done - make the thing idempotent
pyenv install -s
