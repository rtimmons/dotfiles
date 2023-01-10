jenv() {
    if command -v jenv >/dev/null 2>&1; then
        export PATH="$HOME/.jenv/bin:$PATH"
        eval "$(jenv init -)"
    fi
}

