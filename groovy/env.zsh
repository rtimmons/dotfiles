
# Set groovy home if not already set and if installed 
# via homebrew


[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/Cellar/groovy/2.0.0/libexec" ] \
    && export GROOVY_HOME=/usr/local/Cellar/groovy/2.0.0/libexec

# Or try 1.8.6

[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/Cellar/groovy/1.8.6/libexec" ] \
    && export GROOVY_HOME=/usr/local/Cellar/groovy/1.8.6/libexec


