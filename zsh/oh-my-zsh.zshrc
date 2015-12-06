
plugins=(osx brew colored-man-pages gradle pow)

# oh-my-zsh thinks that it owns the ZSH variable.
_ORIG_ZSH="$ZSH"
ZSH="$ZSH/oh-my-zsh"
    source "$ZSH/oh-my-zsh.sh"
ZSH="${_ORIG_ZSH}"
unset _ORIG_ZSH
