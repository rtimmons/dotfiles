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
# MAKE_OPTS="-j8" CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-computed-gotos" CFLAGS="-march=native -O2 -pipe" pyenv install -s 3.7.0
export MAKEFLAGS=""
mkdir -p "$(pyenv root)/versions/3.7.0"
MAKE_OPTS="-j8" CONFIGURE_OPTS="--enable-framework --enable-optimizations --with-computed-gotos --enable-framework=$(pyenv root)/versions/3.7.0/" CFLAGS="-march=native -O2 -pipe" pyenv install -s 3.7.0

