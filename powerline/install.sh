#!/usr/bin/env bash

cd "$(dirname "$0")"

if [ ! -d "powerlevel10k" ]; then
    git clone https://github.com/romkatv/powerlevel10k.git powerlevel10k
else
    pushd powerlevel10k
    git pull
fi

pip install powerline-status
