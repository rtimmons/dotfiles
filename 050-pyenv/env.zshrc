#!/usr/bin/env bash

if command -v pyenv >/dev/null 2>&1; then
    eval "$(command pyenv init -)"
fi

if command -v brew >/dev/null 2>&1; then
    if openssl_prefix="$(brew --prefix openssl 2>/dev/null)" && [ -d "$openssl_prefix" ]; then
        if command -v xcrun >/dev/null 2>&1; then
            sdk_path="$(xcrun -show-sdk-path 2>/dev/null)"
            if [ -n "$sdk_path" ]; then
                export CPPFLAGS="-I${openssl_prefix}/include -I${sdk_path}/usr/include ${CPPFLAGS:-}"
            else
                export CPPFLAGS="-I${openssl_prefix}/include ${CPPFLAGS:-}"
            fi
        else
            export CPPFLAGS="-I${openssl_prefix}/include ${CPPFLAGS:-}"
        fi
        export LDFLAGS="-L${openssl_prefix}/lib ${LDFLAGS:-}"
    fi
fi