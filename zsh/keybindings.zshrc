
# emacs keybindings
bindkey -e

# The following come from `atuin init zsh` which is run before this keybindings file.
#     bindkey '^r' _atuin_search_widget
#     bindkey '^[[A' _atuin_up_search_widget
#     bindkey '^[OA' _atuin_up_search_widget
# so let's not overwrite that for ctrl+r, ctrl+i
#     _bindkey '^r' history-incremental-search-backward
#.    _bindkey '^I' complete-word # complete on tab, leave expansion to _expand

_bindkey "^[[5~" up-line-or-history
_bindkey "^[[6~" down-line-or-history
_bindkey "^[[H" beginning-of-line
_bindkey "^[[1~" beginning-of-line
_bindkey "^[[F"  end-of-line
_bindkey "^[[4~" end-of-line
_bindkey "^[[1;5C" forward-word
_bindkey "^[[1;5D" backward-word
_bindkey '^X^H' run-help

# https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/key-bindings.zsh
# make search up and down work, so partially type and hit up/down to find relevant stuff
# _bindkey '^[[A' up-line-or-search
# _bindkey '^[[B' down-line-or-search

## I hate this option:  I think.
# bindkey ' ' magic-space    # also do history expansion on space


# https://raw.github.com/robbyrussell/oh-my-zsh/master/lib/misc.zsh
## file rename magick
_bindkey "^[m" copy-prev-shell-word
