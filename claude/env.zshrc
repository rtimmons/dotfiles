#!/usr/bin/env zsh

claude() {
    cd "${0:A:h}" && $(brew --prefix nvm)/nvm-exec claude "$@"
}
