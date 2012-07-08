# All kinds of ways to be lazy

## Alias to recursively remove all .DS_Store files (on Macs) ##
alias rmds_store="find . -iname '*DS_Store' -exec rm {} \;"

##### Common Aliases #####
alias        com="gcc -Wall -g -o"
alias   markdown="$ZSH/bin/Markdown.pl"
alias     finder="open -a Finder"
alias         f.="open -a Finder ."
alias        fin="open -a Finder"
alias     remake="make clean; make"

# Kerberos init
alias          k="kinit -f -l 7d"

##### Directory navigating commands #####
alias        ..='cd ..'
alias       ..2="cd ../.."
alias       ..3="cd ../../.."
alias       ..4="cd ../../../.."
alias       ..5="cd ../../../../.."
# same ..2
alias       ...="cd ../.."
# same as ..3
alias      ....="cd ../../.."
alias      cd..='cd ..'
alias       cdd="cd -"
alias      cdwd='cd $(/bin/pwd)'
alias       cwd='echo $PWD'
# dirstack operations:
alias         d="dirs"
alias         p="popd"
alias        pu="pushd"


# Completion is annoying with mv, cp, etc.
# http://dotfiles.org/~_why/.zshrc
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'
alias mkdir='nocorrect mkdir'

# https://raw.github.com/holman/dotfiles/master/system/aliases.zsh
# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if (( $+commands[grc] )); then
    alias ls="gls -F --color"
    alias sl="gls -F --color"
    alias l="gls -lAh --color"
    alias ll="gls -l --color"
    alias la='gls -A --color'
fi


alias cx="chmod +x"
alias cw="chmod +w"
alias cRw="chmod -R +w"

