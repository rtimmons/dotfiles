if [ $+commands[go] ]; then
    if [ $+commands[brew] ]; then
    BREW_PREFIX="$(brew --prefix)"
    add_to_path "$BREW_PREFIX/opt/go/libexec/bin"
    add_to_path "$BREW_PREFIX/opt/go/bin"
    export GOPATH="$BREW_PREFIX/opt/go"
    fi
fi

