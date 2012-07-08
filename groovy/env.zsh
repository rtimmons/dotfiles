
# Set groovy home if not already set and if 1.8.6 installed 
# via homebrew

[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/Cellar/groovy/1.8.6/libexec" ] \
    && export GROOVY_HOME=/usr/local/Cellar/groovy/1.8.6/libexec
