#!/usr/bin/env bash

set -eou pipefail

pushd "$(dirname "$0")" >/dev/null
    self_dir="$(pwd -P)"
popd >/dev/null

parent_dir="$HOME/Library/Application Support/Code/User"

if [[ -d "$parent_dir" ]]; then
    if [[ -L "$parent_dir/settings.json" ]]; then
        echo "vscode settings already linked $parent_dir/settings.json -> $(readlink "$parent_dir/settings.json")"
    elif [[ -f "$parent_dir/settings.json" ]]; then
        echo "Existing [$parent_dir/settings.json] file"
        exit 1
    else
        ln -s "$self_dir/settings.json" "$parent_dir/settings.json"
    fi
fi
