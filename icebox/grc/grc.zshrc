source_if_exists "$BREW_PREFIX/etc/grc.bashrc"


# https://raw.github.com/holman/dotfiles/master/system/aliases.zsh
# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
# TODO: http://hocuspokus.net/2008/01/a-better-ls-for-mac-os-x/
if command -v gls >/dev/null 2>&1; then
    alias ls="gls -F --color"
    alias sl="gls -F --color"
    alias l="gls -lAh --color"
    alias ll="gls -l --color"
    alias la='gls -A --color'
fi
