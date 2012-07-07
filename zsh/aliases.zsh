# All kinds of ways to be lazy

##### ssh shortcuts #####
alias ganon="ssh rtimmons@ganon.com"
alias sshX="ssh -X"
alias xsh="ssh -X"

##### Emacs cleaning commands #####
alias clemacs="rm *\~; rm \#*\#"
alias clemacsd="rm .*\~;"
alias sclemacs="sudo rm *\~; rm \#*\#"
alias sclemacsd="sudo rm .*\~"

## Alias to recursively remove all .DS_Store files (on Macs) ##
alias rmds_store="find . -iname '*DS_Store' -exec rm {} \;"

##### Common Aliases #####
alias        com="gcc -Wall -g -o"
alias   markdown="$ZSH/bin/Markdown.pl"
alias     finder="open -a Finder"
alias         f.="open -a Finder ."
alias        fin="open -a Finder"
alias          m="mate"
alias         m.="mate ."
alias         ee="emacs -nw"
alias        see="sudo emacs -nw"
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
# ls ops:
alias         l='ls -lg'
alias       dot='ls .[a-zA-Z0-9_]*'
alias       dir='ls -ba'
alias        la='ls -A'
alias        lA='ls -a'
alias        ll="ls -l"
# Because I'm lysdexic:
alias        sl="ls"

alias cx="chmod +x"
alias cw="chmod +w"
alias cRw="chmod -R +w"

