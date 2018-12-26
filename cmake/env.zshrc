if [ -z "$CPLUS_INCLUDE_PATH"]; then
    export CPLUS_INCLUDE_PATH="$(brew --prefix)/include"
fi

if [ -z "$LIBRARY_PATH" ]; then
    export LIBRARY_PATH="$(brew --prefix)/lib/:$LIBRARY_PATH"
fi

