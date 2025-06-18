jenv() {
    if command -v jenv >/dev/null 2>&1; then
        add_to_path "$HOME/.jenv/bin"
        eval "$(jenv init -)"
    fi
}

