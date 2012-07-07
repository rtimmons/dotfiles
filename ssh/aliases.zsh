
# https://github.com/holman/dotfiles/blob/master/system/keys.zsh

alias hosts="head -2 ~/.ssh/known_hosts | tail -1 > ~/.ssh/known_hosts"
alias pubkey="cat ~/.ssh/id_dsa.public | pbcopy | echo '=> Public key copied to pasteboard.'"
