
# Init autojump if installed via homebrew
if (( $+commands[brew] )); then
    if [ -s `brew --prefix`/etc/autojump.sh ]; then
        source "`brew --prefix`/etc/autojump.sh"
    fi
fi
