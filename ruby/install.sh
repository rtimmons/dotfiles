#!/usr/bin/env bash
set -euo pipefail

brew install --quiet rbenv
brew install --quiet ruby-build

eval "$(rbenv init -)"

rbenv install -s

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
