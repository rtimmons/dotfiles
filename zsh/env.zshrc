PFX="${BREW_PREFIX}"
if [ -d "$PFX/share/zsh-completions" ]; then
    fpath=($PFX/share/zsh-completions $fpath)
fi
