#!/usr/bin/env bash

# TODO: look into https://dev.to/matrixersp/how-to-use-fzf-with-ripgrep-to-selectively-ignore-vcs-files-4e27 or similar

if command -v fzf >/dev/null 2>&1; then
    PFX="$(brew --prefix fzf)"
    # Setup fzf
    # ---------
    if [[ ! "$PATH" == *$PFX* ]]; then
      export PATH="$PATH:$PFX/bin"
    fi

    # Auto-completion
    # ---------------
    [[ $- == *i* ]] \
        && source "$PFX/shell/completion.zsh" 2> /dev/null

    # Key bindings
    # ------------
    source "$PFX/shell/key-bindings.zsh"

    alias ff="fzf --preview 'bat --color \"always\" {}'"
    # add support for ctrl+o to open selected file in VS Code
    export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(mate {})+abort'"

fi
