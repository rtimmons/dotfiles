if (( $+commands[bat] )); then
    export LESS="-r"
    alias cat=bat
    bless() {
        bat --color always "$@" | less
    }
fi
