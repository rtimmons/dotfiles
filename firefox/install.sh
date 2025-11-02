#!/usr/bin/env bash

set -eou pipefail

brew install --quiet firefoxpwa

profile_root="${HOME}/Library/Application Support/Firefox/Profiles"
chrome_dir="$(cd "$(dirname "$0")" && pwd -P)/chrome"

if [ ! -d "${chrome_dir}" ]; then
    exit 0
fi

if [ ! -d "${profile_root}" ]; then
    exit 0
fi

status=0

for profile in "${profile_root}"/*; do
    [ -d "$profile" ] || continue
    link_path="${profile}/chrome"
    if [ -L "$link_path" ]; then
        current_target="$(readlink "$link_path")"
        if [ "$current_target" != "$chrome_dir" ]; then
            rm "$link_path"
            ln -s "$chrome_dir" "$link_path"
            printf 'firefox: relinked chrome for %s\n' "$(basename "$profile")"
        fi
    elif [ -e "$link_path" ]; then
        printf 'firefox: %s exists and is not a symlink\n' "$link_path" >&2
        status=1
    else
        ln -s "$chrome_dir" "$link_path"
        printf 'firefox: linked chrome for %s\n' "$(basename "$profile")"
    fi
done

exit "$status"
