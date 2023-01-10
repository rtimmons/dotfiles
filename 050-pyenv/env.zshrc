#!/usr/bin/env bash

pyenv() {
    if which pyenv > /dev/null; then
        eval "$(command pyenv init -)"
        eval "$(command pyenv init --path)"
    fi

    _openssl=$(brew --prefix openssl)
    export CPPFLAGS="-I${_openssl}/include -I$(xcrun -show-sdk-path)/usr/include ${CPPFLAGS:-}"
    export LDFLAGS="-L${_openssl}/lib ${LDFLAGS:-}"
    command pyenv "$@"
}
