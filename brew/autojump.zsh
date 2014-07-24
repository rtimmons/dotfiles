
# Init autojump if installed via homebrew
if (( $+commands[brew] )); then
    [[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh
fi
