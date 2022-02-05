#!/usr/bin/env bash

if [[ ! -e "./micro" ]]; then
    exit 0
fi
echo "Installing micro"
curl https://getmic.ro | bash
