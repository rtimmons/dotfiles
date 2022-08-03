{
    PFX=$(brew --prefix)
    # brew install zsh-syntax-highlighting
    local f="$PFX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [ -f "$f" ]; then
        source "$f"
        export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$PFX/share/zsh-syntax-highlighting/highlighters"
    fi
}
