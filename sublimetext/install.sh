#!/usr/bin/env bash

set -euo pipefail

self_dir="$(cd "$(dirname "$0")" && pwd -P)"
source_user_dir="$self_dir/Packages/User"
target_user_dir="$HOME/Library/Application Support/Sublime Text/Packages/User"

if [[ ! -d "$source_user_dir" ]]; then
    printf 'sublimetext: missing source directory: %s\n' "$source_user_dir" >&2
    exit 1
fi

mkdir -p "$target_user_dir"

status=0

while IFS= read -r -d '' source_path; do
    rel_path="${source_path#"$source_user_dir"/}"
    target_path="$target_user_dir/$rel_path"

    mkdir -p "$(dirname "$target_path")"

    if [[ -L "$target_path" ]]; then
        current_target="$(readlink "$target_path")"
        if [[ "$current_target" != "$source_path" ]]; then
            rm "$target_path"
            ln -s "$source_path" "$target_path"
        fi
    elif [[ -e "$target_path" ]]; then
        printf 'sublimetext: %s exists and is not a symlink\n' "$target_path" >&2
        status=1
    else
        ln -s "$source_path" "$target_path"
    fi
done < <(
    find "$source_user_dir" -type f \
        \( \
            -name '*.py' -o \
            -name '*.sublime-build' -o \
            -name '*.sublime-commands' -o \
            -name '*.sublime-keymap' -o \
            -name '*.sublime-menu' -o \
            -name '*.sublime-settings' -o \
            -name '*.sublime-snippet' \
        \) \
        -print0 | LC_ALL=C sort -z
)

if ! command -v duti >/dev/null 2>&1; then
    brew install --quiet duti
fi

# Code and config file types managed or implied by this repo.
# Files without extensions (Makefile, Rakefile, Dockerfile, justfile) cannot be
# claimed by duti, which requires an extension or UTI.
exts=(
    sh bash zsh             # shell scripts and configs
    py                      # Python (pyenv, pipx, poetry, virtualenv)
    pl pm                   # Perl
    lua                     # Hammerspoon
    el                      # Emacs Lisp
    c h                     # C
    css html htm            # web
    md txt                  # plain text / Markdown
    json toml xml           # structured data
    yaml yml                # YAML
    env envrc               # direnv, dotenv
    conf cfg ini            # generic config
    go                      # Go
    rb                      # Ruby (rbenv)
    rs                      # Rust
    js mjs cjs              # Node / nvm
    ts tsx jsx              # TypeScript (cursor, vscode)
    groovy gradle           # Groovy / Gradle
    tex bib sty cls         # LaTeX (mactex, texlive)
)

for ext in "${exts[@]}"; do
    duti -s com.sublimetext.4 ".$ext" all 2>/dev/null || true
done

exit "$status"
