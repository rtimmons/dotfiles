
###
# Shell Options
####

# TODO: maybe enable this?
# setopt MENUCOMPLETE 

# TODO: would be nice to give info on what these actually do

# http://www.cs.elte.hu/zsh-manual/zsh_16.html

setopt  AUTO_CD
setopt  AUTO_LIST #Automatically list choices on an ambiguous completion.
setopt  AUTO_MENU
setopt  AUTO_PUSHD
setopt  AUTO_RESUME
setopt  BSD_ECHO            # Make the echo builtin compatible with the BSD echo(1) command (require -e)
setopt  COMPLETE_IN_WORD
setopt  COMPLETE_ALIASES # don't expand aliases _before_ completion has finished
setopt  CORRECT
setopt  CORRECTALL
setopt  EXTENDEDGLOB
setopt  EXTENDED_HISTORY # add timestamps to history
setopt  HASH_CMDS
setopt  HASH_DIRS
setopt  INTERACTIVECOMMENTS # INTERACTIVECOMMENTS turns on interactive comments; comments begin with a #. [1]
setopt  LOCAL_OPTIONS # allow functions to have local options
setopt  LOCAL_TRAPS # allow functions to have local traps
setopt  LONGLISTJOBS
setopt  MAILWARNING
setopt  NOTIFY
setopt  NO_AUTOPARAMSLASH
setopt  NO_BG_NICE # don't nice background tasks
setopt  NO_FLOW_CONTROL
setopt  NO_HUP
setopt  NO_LIST_BEEP
setopt  NO_MENU_COMPLETE   # do not autoselect the first completion entry
setopt  PROMPT_SUBST
setopt  RM_STAR_SILENT # http://dotfiles.org/~mental/.zshrc
setopt  PUSHD_MINUS
setopt  PUSHD_SILENT
setopt  PUSHD_TO_HOME    # Have pushd with no arguments act like pushd $HOME.
setopt  RCQUOTES
setopt  RECEXACT

# [1]: http://zsh.sourceforge.net/Intro/intro_16.html#SEC16

# http://www.cs.elte.hu/zsh-manual/zsh_16.html:
# 
# The sense of an option name may be inverted by preceding it with no, so setopt No_Beep is equivalent to unsetopt
# beep. This inversion can only be done once, so nonobeep is not a synonym for beep. Similarly, tify is not a synonym
# for nonotify (the inversion of notify).

# Autoload zsh modules when they are referenced
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile

zle -N newtab

# https://raw.github.com/robbyrussell/oh-my-zsh/master/lib/misc.zsh
## smart urls
autoload -U url-quote-magic
zle -N self-insert url-quote-magic




export LC_TYPE="en_US.UTF-8"
export LANG="$LC_TYPE"
export PAGER="less -R"

