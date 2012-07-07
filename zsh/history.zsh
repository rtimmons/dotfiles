# History stuff
setopt  APPEND_HISTORY # adds history
setopt  EXTENDED_HISTORY # puts timestamps in the history
setopt  HISTIGNOREDUPS
setopt  HIST_ALLOW_CLOBBER
setopt  HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt  HIST_IGNORE_SPACE
setopt  HIST_REDUCE_BLANKS
setopt  HIST_VERIFY
setopt  INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions

# TODO: not sure about these
# setopt  INC_APPEND_HISTORY zsh_history
# setopt  SHARE_HISTORY # share history between sessions ???

export HISTFILE="$HOME/.history"
export HISTSIZE=2000
