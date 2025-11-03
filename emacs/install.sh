#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PRELUDE_REMOTE="https://github.com/bbatsov/prelude.git"
EMACSD_DIR="${HOME}/.emacs.d"
PRELUDE_PERSONAL_DIR="${SCRIPT_DIR}/prelude-personal"

if ! brew list --cask emacs >/dev/null 2>&1; then
    brew install --cask --quiet emacs
fi

if [ -d "${EMACSD_DIR}/.git" ]; then
    git -C "${EMACSD_DIR}" fetch --quiet --tags
    default_branch="$(git -C "${EMACSD_DIR}" remote show origin | awk '/HEAD branch/ {print $NF}')"
    if [ -n "${default_branch}" ]; then
        git -C "${EMACSD_DIR}" checkout --quiet "${default_branch}"
        git -C "${EMACSD_DIR}" reset --quiet --hard "origin/${default_branch}"
    else
        git -C "${EMACSD_DIR}" pull --ff-only --quiet
    fi
else
    git clone --depth 1 --quiet "${PRELUDE_REMOTE}" "${EMACSD_DIR}"
fi

ln -sfn "${PRELUDE_PERSONAL_DIR}" "${EMACSD_DIR}/personal"
