#!/usr/bin/env bash

pushd "$(dirname "$0")" >/dev/null
    self_dir="$(pwd -P)"
popd >/dev/null

parent_dir="/Users/rtimmons/Library/Application Support/Code/User"

ln -s "$self_dir/settings.json" "$parent_dir/settings.json"
