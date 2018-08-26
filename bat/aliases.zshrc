if (( $+commands[bat] )); then
    alias cat=bat
    bless() {
        bat --color always "$@" | less -r
    }
fi
