# History stuff

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=5000
export SAVEHIST=$HISTSIZE


##############################################################################

setopt  APPEND_HISTORY

# APPEND_HISTORY <D>
#        If  this  is set, zsh sessions will append their history list to
#        the history file, rather than replace it. Thus, multiple  paral-
#        lel  zsh  sessions will all have the new entries from their his-
#        tory lists added to the history file, in  the  order  that  they
#        exit.  The file will still be periodically re-written to trim it
#        when the number of lines grows 20% beyond the value specified by
#        $SAVEHIST (see also the HIST_SAVE_BY_COPY option).
# 

##############################################################################

setopt  EXTENDED_HISTORY

# EXTENDED_HISTORY <C>
#        Save each command's beginning timestamp (in  seconds  since  the
#        epoch)  and  the duration (in seconds) to the history file.  The
#        format of this prefixed data is:
# 
#        `: <beginning time>:<elapsed seconds>;<command>'.

##############################################################################

setopt  HIST_ALLOW_CLOBBER

# HIST_ALLOW_CLOBBER
#        Add `|' to output redirections in the history.  This allows his-
#        tory references to clobber files even when CLOBBER is unset.

##############################################################################

setopt  HIST_EXPIRE_DUPS_FIRST

# HIST_EXPIRE_DUPS_FIRST
#        If the internal history needs to be trimmed to add  the  current
#        command  line, setting this option will cause the oldest history
#        event that has a duplicate to be lost  before  losing  a  unique
#        event  from  the  list.   You should be sure to set the value of
#        HISTSIZE to a larger number than SAVEHIST in order to  give  you
#        some  room for the duplicated events, otherwise this option will
#        behave just like HIST_IGNORE_ALL_DUPS once the history fills  up
#        with unique events.

##############################################################################

setopt  HIST_IGNORE_SPACE

# HIST_IGNORE_SPACE (-g)
#        Remove command lines from the history list when the first  char-
#        acter  on  the  line  is  a  space,  or when one of the expanded
#        aliases contains a leading  space.   Only  normal  aliases  (not
#        global  or  suffix  aliases) have this behaviour.  Note that the
#        command lingers in the internal history until the  next  command
#        is  entered before it vanishes, allowing you to briefly reuse or
#        edit the line.  If you want to make it vanish right away without
#        entering another command, type a space and press return.

##############################################################################

setopt  HIST_REDUCE_BLANKS

# HIST_REDUCE_BLANKS
#        Remove superfluous blanks from each command line being added  to
#        the history list.

##############################################################################

setopt  HIST_VERIFY

# HIST_VERIFY
#        Whenever  the  user  enters a line with history expansion, don't
#        execute the line directly; instead,  perform  history  expansion
#        and reload the line into the editing buffer.


##############################################################################

setopt  INC_APPEND_HISTORY

# INC_APPEND_HISTORY
#        This  options  works like APPEND_HISTORY except that new history
#        lines are added to the $HISTFILE incrementally (as soon as  they
#        are  entered),  rather  than waiting until the shell exits.  The
#        file will still be periodically re-written to trim it  when  the
#        number  of  lines grows 20% beyond the value specified by $SAVE-
#        HIST (see also the HIST_SAVE_BY_COPY option).


##############################################################################

setopt  SHARE_HISTORY

# SHARE_HISTORY <K>
#        This option both imports new commands from the history file, and
#        also  causes  your  typed commands to be appended to the history
#        file (the latter is like  specifying  INC_APPEND_HISTORY).   The
#        history  lines are also output with timestamps ala EXTENDED_HIS-
#        TORY (which makes it easier to find the spot where we  left  off
#        reading the file after it gets re-written).
# 
#        By  default,  history movement commands visit the imported lines
#        as well as the local lines, but you can toggle this on  and  off
#        with  the set-local-history zle binding.  It is also possible to
#        create a zle widget that will make some commands ignore imported
#        commands, and some include them.
# 
#        If  you  find  that you want more control over when commands get
#        imported,   you   may   wish   to   turn   SHARE_HISTORY    off,
#        INC_APPEND_HISTORY  on,  and then manually import commands when-
#        ever you need them using `fc -RI'.


##############################################################################
