export NVM_DIR="$HOME/.nvm"

#
# Adopted from https://www.growingwiththeweb.com/2018/01/slow-nvm-init.html
# made to work on zsh
#

PFX="${BREW_PREFIX:-${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null)}}"
[ -z "$PFX" ] && [ -d /opt/homebrew ] && PFX=/opt/homebrew
[ -z "$PFX" ] && [ -d /usr/local ] && PFX=/usr/local

# Defer initialization of nvm until nvm, node or a node-dependent command is
# run. Ensure this block is only run once if .bashrc gets sourced multiple times
# by checking whether __init_nvm is a function.
if [[ "$(whence -w __init_nvm)" != "__init_nvm: function" ]]; then
    if [ -s "$PFX/opt/nvm/etc/bash_completion.d/nvm" ]; then
        source "$PFX/opt/nvm/etc/bash_completion.d/nvm"
    fi
    __node_commands=('nvm' 'node' 'npm' 'yarn' 'gulp' 'grunt' 'webpack')
    function __init_nvm() {
      for i in "${__node_commands[@]}"; do
          unalias "$i" 2>/dev/null
      done
      [ -s "$PFX/opt/nvm/nvm.sh" ] && source "$PFX/opt/nvm/nvm.sh"
      unset __node_commands
      unset -f __init_nvm
    }
    for i in "${__node_commands[@]}"; do
        alias $i='__init_nvm && '$i
    done
fi
