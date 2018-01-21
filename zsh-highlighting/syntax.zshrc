{
    # brew install zsh-syntax-highlighting
    local f="/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [ -f "$f" ]; then
        source "$f"
        export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="/usr/local/share/zsh-syntax-highlighting/highlighters"
    fi
}
