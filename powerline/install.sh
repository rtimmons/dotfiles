#!/usr/bin/env bash

cd "$(dirname "$0")"

if [ ! -d "powerlevel9k" ]; then
    git clone https://github.com/bhilburn/powerlevel9k.git powerlevel9k
else
    pushd powerlevel9k
    git pull
fi

pip install powerline-status
