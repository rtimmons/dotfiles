#!/usr/bin/env bash

if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv init --path)"
fi

export CPPFLAGS="-I$(brew --prefix openssl)/include -I$(xcrun -show-sdk-path)/usr/include ${CPPFLAGS:-}"
export LDFLAGS="-L$(brew --prefix openssl)/lib ${LDFLAGS:-}"
