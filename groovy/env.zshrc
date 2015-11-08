
# Set groovy home if not already set and if installed 
# via homebrew

[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/opt/groovy/libexec" ] \
    && export GROOVY_HOME=/usr/local/opt/groovy/libexec

# Support alternative homebrew prefix
if [ -z "$GROOVY_HOME" ]; then
    if which brew > /dev/null; then
        if [ -d "$(brew --prefix)"/opt/groovy/libexec ]; then
            export GROOVY_HOME="$(brew --prefix)"/opt/groovy/libexec
        fi
    fi
fi


