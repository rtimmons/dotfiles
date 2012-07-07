
if [ -x '/usr/local/bin/mate' ]; then
    export EDITOR=mate
    export SVNEDITOR=mate
else
    export EDITOR=emacs
fi

