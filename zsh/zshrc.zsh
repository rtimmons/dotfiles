
###
# Shell Options
####

# TODO: maybe enable this?
# setopt MENUCOMPLETE 

# TODO: would be nice to give info on what these actually do
setopt  notify
setopt  globdots 
setopt  correct 
setopt  pushdtohome 
setopt  autolist
setopt  correctall 
setopt  autocd 
setopt  recexact 
setopt  longlistjobs
setopt  setopt   
setopt  autoresume 
setopt  histignoredups 
setopt  pushdsilent 
setopt  setopt   autopushd 
setopt  pushdminus 
setopt  extendedglob 
setopt  rcquotes 
setopt  mailwarning
setopt  CORRECT

unsetopt    bgnice 
unsetopt    autoparamslash


# Autoload zsh modules when they are referenced
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile


export EDITOR=emacs
export LC_TYPE="en_US.UTF-8"
export LANG="$LC_TYPE"

