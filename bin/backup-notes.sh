#!/usr/bin/env bash

# WIP script to backup ~/{Dropbox/Notes, {Projects/Worklogs}

set -eou pipefail
set -x

TMP_DIR="/tmp/$(basename "$0")-$$"
cleanup() {
    rm -rf "$TMP_DIR"
}
# trap cleanup EXIT
mkdir -p "$TMP_DIR"

DATE=$(date +"%Y-%m-%d")
    
DIRS=(
  "$HOME/Dropbox/Notes"
  "$HOME/Projects/Worklogs"
)

run_backup() {
    for DIR in "${DIRS[@]}"; do
        if [ ! -d "$DIR" ]; then
            continue
        fi
        echo "Backing up $DIR"
        # this isn't right...
        echo tar -czf "$TMP_DIR/$(basename "$DIR")-$DATE.tar.gz" -C "$DIR" .
    done
}

run_backup


