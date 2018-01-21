# https://raw.github.com/holman/dotfiles/master/system/grc.zsh

# GRC colorizes nifty unix tools all over the place
if (( $+commands[brew] && $+commands[grc] ));  then
    source `brew --prefix`/etc/grc.bashrc
fi

# bits about $+commands from here:
# 
#     http://www.zsh.org/mla/users/2011/msg00070.html
# 
