
# Init autojump if installed via homebrew
if (( $+commands[brew] )); then
    if [ -f `brew --prefix`/etc/autojump ]; then
      . `brew --prefix`/etc/autojump
    fi
fi
