
# use textmate else emacs

if (( $+commands[mate] )); then
    export EDITOR="mate -w"
    # seems to be broken, but I don't use editing from less anyway
    # export LESSEDIT='mate -l %lm %f'
else
    export EDITOR=emacs
fi

