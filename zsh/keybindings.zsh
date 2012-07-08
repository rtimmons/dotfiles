
# emacs keybindings
bindkey -e

bindkey '^r' history-incremental-search-backward
bindkey "^[[5~" up-line-or-history
bindkey "^[[6~" down-line-or-history
bindkey "^[[H" beginning-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^I' complete-word # complete on tab, leave expansion to _expand
bindkey '^X^H' run-help

# https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/key-bindings.zsh
# make search up and down work, so partially type and hit up/down to find relevant stuff
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

## I hate this option:  I think.
# bindkey ' ' magic-space    # also do history expansion on space


# https://raw.github.com/robbyrussell/oh-my-zsh/master/lib/misc.zsh
## file rename magick
bindkey "^[m" copy-prev-shell-word
