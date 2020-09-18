if command -v go >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
        add_to_path "$BREW_PREFIX/opt/go/libexec/bin"
        add_to_path "$BREW_PREFIX/opt/go/bin"
        add_to_path "$BREW_PREFIX/opt/go" GOPATH
    fi
fi

