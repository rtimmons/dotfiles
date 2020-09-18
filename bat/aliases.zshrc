if command -v bat >/dev/null 2>&1; then
    alias cat=bat
    alias ccat=/bin/cat
    bless() {
        bat --color always "$@" | less -r
    }
fi