
# use textmate else emacs

if command -v mate >/dev/null 2>&1; then
    export EDITOR="mate -w"
    # seems to be broken, but I don't use editing from less anyway
    # export LESSEDIT='mate -l %lm %f'
else
    export EDITOR=emacs
fi

