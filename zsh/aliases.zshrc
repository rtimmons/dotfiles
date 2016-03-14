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
alias      cdwd='cd $(/bin/pwd -P)'
alias      cd.='cd $(/bin/pwd -P)'
alias       cwd='echo $PWD'
# dirstack operations:
alias         d="dirs"
alias         p="popd"
alias        pu="pushd"


# https://raw.github.com/holman/dotfiles/master/system/aliases.zsh
# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
# TODO: http://hocuspokus.net/2008/01/a-better-ls-for-mac-os-x/
if (( $+commands[gls] )); then
    alias ls="gls -F --color"
    alias sl="gls -F --color"
    alias l="gls -lAh --color"
    alias ll="gls -l --color"
    alias la='gls -A --color'
fi


alias cx="chmod +x"
alias cw="chmod +w"
alias cRw="chmod -R +w"


alias "reload!"="source ~/.zshrc"

alias ft="open -a FoldingText"


# Pretty-print javascript
# http://ruslanspivak.com/2010/10/12/pretty-print-json-from-the-command-line/
alias pp='python -c "import sys, json; print json.dumps(
json.load(sys.stdin), sort_keys=True, indent=2)"'

# numberwang is badly-named but cool - lets you easily copy file names from stdout to the clipboard
# see go/notes.txt
alias nw=numberwang

