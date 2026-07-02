#!/usr/bin/env bash
set -euo pipefail

brew install --quiet rbenv
brew install --quiet ruby-build

eval "$(rbenv init -)"

# Install the version pinned in .ruby-version if it isn't already present.
rbenv install -s

# Verify the active build is actually functional. A Ruby whose native
# extensions failed to compile (e.g. the socket extension, which older Rubies
# fail to build on modern macOS because /usr/include no longer exists) will
# appear "installed" to `rbenv install -s` but break every `gem install`.
# If the sanity check fails, force a rebuild once so a cold install
# self-heals instead of leaving a half-broken interpreter.
if ! ruby -e 'require "socket"; require "openssl"' >/dev/null 2>&1; then
    version="$(rbenv version-name)"
    echo "Ruby ${version} is missing core extensions; rebuilding..." >&2
    rbenv install -f "$version"
fi

rbenv rehash

install_gem() {
    local gem_name="$1"
    if gem list -i "$gem_name" >/dev/null 2>&1; then
        return
    fi
    gem install --no-document "$gem_name"
}

install_gem rbenv-rehash
install_gem map_by_method
install_gem what_methods
install_gem pp
install_gem awesome_print
install_gem activesupport
install_gem business_time
