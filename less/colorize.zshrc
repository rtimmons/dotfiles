if [ -x "$ZSH/less/lesspipe.sh" ]; then
    export LESSOPEN="|$ZSH/less/lesspipe.sh %s"
    export LESS="-r"
fi

# export LESSCOLORIZER=pygmentize
