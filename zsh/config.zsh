
###
# Shell Options
####

# TODO: maybe enable this?
# setopt MENUCOMPLETE 

# TODO: would be nice to give info on what these actually do

setopt  AUTOCD
setopt  AUTOLIST
setopt  AUTOPUSHD
setopt  AUTORESUME
setopt  COMPLETE_IN_WORD
setopt  COMPLETE_ALIASES # don't expand aliases _before_ completion has finished
setopt  CORRECT
setopt  CORRECTALL
setopt  EXTENDEDGLOB
setopt  EXTENDED_HISTORY # add timestamps to history
setopt  GLOBDOTS
setopt  IGNORE_EOF
setopt  LOCAL_OPTIONS # allow functions to have local options
setopt  LOCAL_TRAPS # allow functions to have local traps
setopt  LONGLISTJOBS
setopt  MAILWARNING
setopt  NOTIFY
setopt  NO_BG_NICE # don't nice background tasks
setopt  NO_HUP
setopt  NO_LIST_BEEP
setopt  PROMPT_SUBST
setopt  PUSHDMINUS
setopt  PUSHDSILENT
setopt  PUSHDTOHOME
setopt  RCQUOTES
setopt  RECEXACT

unsetopt    BGNICE 
unsetopt    AUTOPARAMSLASH

# Autoload zsh modules when they are referenced
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile


fpath=($ZSH/zsh/functions $fpath)
autoload -U $ZSH/zsh/functions/*(:t)

zle -N newtab

export EDITOR=emacs
export LC_TYPE="en_US.UTF-8"
export LANG="$LC_TYPE"

