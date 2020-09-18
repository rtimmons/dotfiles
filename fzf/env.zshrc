if command -v fzf >/dev/null 2>&1; then
    # Setup fzf
    # ---------
    if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
      export PATH="$PATH:/usr/local/opt/fzf/bin"
    fi

    # Auto-completion
    # ---------------
    [[ $- == *i* ]] \
        && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

    # Key bindings
    # ------------
    source "/usr/local/opt/fzf/shell/key-bindings.zsh"

    alias ff="fzf --preview 'bat --color \"always\" {}'"
    # add support for ctrl+o to open selected file in VS Code
    export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(code {})+abort'"
fi
