add_to_path "$ZSH/sublimetext/bin"

if command -v subl >/dev/null 2>&1; then
    export EDITOR="subl -n -w"
    export VISUAL="$EDITOR"
elif command -v mate >/dev/null 2>&1; then
    export EDITOR="mate -w"
    export VISUAL="$EDITOR"
fi
