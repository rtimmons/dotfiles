#!/usr/bin/env bash

set -eou pipefail

self_dir="$(cd "$(dirname "$0")" && pwd -P)"
settings_dir="$HOME/Library/Application Support/Code/User"
target="$settings_dir/settings.json"
source_path="$self_dir/settings.json"

if [[ ! -d "$settings_dir" ]]; then
    exit 0
fi

if [[ -L "$target" ]]; then
    current="$(readlink "$target")"
    if [[ "$current" != "$source_path" ]]; then
        rm "$target"
        ln -s "$source_path" "$target"
        printf 'vscode: relinked settings.json\n'
    fi
elif [[ -e "$target" ]]; then
    printf 'vscode: %s exists and is not a symlink\n' "$target" >&2
    exit 1
else
    ln -s "$source_path" "$target"
    printf 'vscode: linked settings.json\n'
fi
