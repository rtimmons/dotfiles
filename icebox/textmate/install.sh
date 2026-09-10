#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEXTMATE_BUNDLES_DIR="$HOME/Library/Application Support/TextMate/Bundles"

BUNDLES=(
    "RyBundle.tmbundle"
    "Themes.tmbundle"
    "Markdown (GitHub) Font Settings.tmbundle"
)

mkdir -p "$TEXTMATE_BUNDLES_DIR"

status=0

for bundle in "${BUNDLES[@]}"; do
    bundle_source="$SCRIPT_DIR/$bundle"
    bundle_link="$TEXTMATE_BUNDLES_DIR/$bundle"

    if [ ! -d "$bundle_source" ]; then
        printf 'textmate: bundle source missing: %s\n' "$bundle_source" >&2
        status=1
        continue
    fi

    if [ -L "$bundle_link" ]; then
        current_target="$(readlink "$bundle_link")"
        if [ "$current_target" != "$bundle_source" ]; then
            rm "$bundle_link"
            ln -s "$bundle_source" "$bundle_link"
        fi
    elif [ -e "$bundle_link" ]; then
        printf 'textmate: %s exists and is not a symlink\n' "$bundle_link" >&2
        status=1
    else
        ln -s "$bundle_source" "$bundle_link"
    fi
done

# Avoid heavy session restores on launch.
if ! defaults write com.macromates.TextMate disableSessionRestore -bool true; then
    printf 'textmate: failed to set disableSessionRestore\n' >&2
    status=1
fi

exit "$status"