if [ $+commands[go] ]; then
    if [ -n $+commands[brew] ]; then
        add_to_path "$BREW_PREFIX/opt/go/libexec/bin"
        add_to_path "$BREW_PREFIX/opt/go/bin"
        add_to_path "$BREW_PREFIX/opt/go" GOPATH
    fi
fi

