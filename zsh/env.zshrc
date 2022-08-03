PFX="$(brew --prefix)"
if [ -d "$PFX/share/zsh-completions" ]; then
    fpath=($PFX/share/zsh-completions $fpath)
fi
