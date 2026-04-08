if command -v bat >/dev/null 2>&1; then
    alias cat=bat
    alias ccat=/bin/cat
    bless() {
        if command -v glow >/dev/null 2>&1 && [[ $# -eq 1 && "$1" == *.md ]]; then
            glow --pager "$1"
        else
            bat --color always "$@" | less -r
        fi
    }
fi