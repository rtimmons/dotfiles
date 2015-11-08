# Accessing online help as supplied by the homebrew version of zsh (`brew install zsh`)
if [ -d "/usr/local/share/zsh/helpfiles" ]; then
    unalias run-help
    autoload run-help
    HELPDIR=/usr/local/share/zsh/helpfiles
fi
