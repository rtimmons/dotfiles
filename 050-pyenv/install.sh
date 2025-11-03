#!/usr/bin/env bash
set -euo pipefail

brew install --quiet pyenv

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv init --path)"
fi

# dependencies for installing later versions of python through pyenv
brew install --quiet readline
brew install --quiet zlib
brew install --quiet sqlite

PFX="${BREW_PREFIX:-$(brew --prefix)}"
# https://github.com/jiansoung/issues-list/issues/13
export LDFLAGS="${LDFLAGS:-} -L$PFX/opt/zlib/lib"
export CPPFLAGS="${CPPFLAGS:-} -I$PFX/opt/zlib/include"
export LDFLAGS="${LDFLAGS:-} -L$PFX/opt/sqlite/lib"
export CPPFLAGS="${CPPFLAGS:-} -I$PFX/opt/sqlite/include"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-} $PFX/opt/zlib/lib/pkgconfig"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-} $PFX/opt/sqlite/lib/pkgconfig"

if [ ! -e "$(pyenv root)/plugins/pyenv-doctor" ]; then
    git clone --quiet https://github.com/pyenv/pyenv-doctor.git "$(pyenv root)/plugins/pyenv-doctor"
fi

ensure_python_version() {
    local version_file=$1
    local source_label=$2

    if [ ! -f "$version_file" ]; then
        return
    fi

    local desired_version
    desired_version="$(tr -d '[:space:]' < "$version_file")"
    if [ -z "$desired_version" ]; then
        return
    fi

    if pyenv prefix "$desired_version" >/dev/null 2>&1; then
        return
    fi

    local log_file
    log_file="$(mktemp "${TMPDIR:-/tmp}/pyenv-install.XXXXXX")"
    if pyenv install "$desired_version" >"$log_file" 2>&1; then
        rm -f "$log_file"
        return
    fi

    cat "$log_file" >&2
    rm -f "$log_file"
    printf 'pyenv install %s failed (from %s)\n' "$desired_version" "$source_label" >&2
    return 1
}

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

ensure_python_version "$script_dir/python-version.symlink" "050-pyenv/python-version.symlink"

while IFS= read -r -d '' version_file; do
    rel_path="${version_file#"$repo_root"/}"
    ensure_python_version "$version_file" "$rel_path"
done < <(find "$repo_root" -type f -name '.python-version' -print0)
