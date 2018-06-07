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

alias huuid="echo \"HEADER_\$(uuidgen | sed s/-/_/g)_INCLUDED\""

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

iname() {
    f="$1"
    shift
    find . -iname "*$f*" "$@"
}

