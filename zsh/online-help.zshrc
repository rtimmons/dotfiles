PFX=$(brew --prefix)
# Accessing online help as supplied by the homebrew version of zsh (`brew install zsh`)
if [ -d "$PFX/share/zsh/helpfiles" ]; then
    unalias run-help
    autoload run-help
    HELPDIR="$PFX/share/zsh/helpfiles"
fi
