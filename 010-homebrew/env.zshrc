
# add_to_path /usr/local/bin
add_to_path /usr/local/sbin

# Homebrew seems to like to put completions here:
if [ -d "/usr/local/share/zsh/site-functions" ]; then
    fpath=($fpath /usr/local/share/zsh/site-functions)
    setopt NULL_GLOB
        autoload -U /usr/local/share/zsh/site-functions/*(:t) 2>/dev/null
    unsetopt NULL_GLOB
fi

export HOMEBREW_NO_AUTO_UPDATE=1
