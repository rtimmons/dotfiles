#!/usr/bin/env bash

brew install --quiet pyenv

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv init --path)"
fi

# dependencies for installing later versions of python through pyenv
brew install --quiet readline
brew install --quiet zlib
brew install --quiet sqlite

PFX="${BREW_PREFIX}"
# https://github.com/jiansoung/issues-list/issues/13
export LDFLAGS="${LDFLAGS} -L$PFX/opt/zlib/lib"
export CPPFLAGS="${CPPFLAGS} -I$PFX/opt/zlib/include"
export LDFLAGS="${LDFLAGS} -L$PFX/opt/sqlite/lib"
export CPPFLAGS="${CPPFLAGS} -I$PFX/opt/sqlite/include"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} $PFX/opt/zlib/lib/pkgconfig"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} $PFX/opt/sqlite/lib/pkgconfig"

if [ ! -e "$(pyenv root)/plugins/pyenv-doctor" ]; then
    git clone --quiet https://github.com/pyenv/pyenv-doctor.git "$(pyenv root)/plugins/pyenv-doctor"
fi
