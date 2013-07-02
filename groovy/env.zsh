
# Set groovy home if not already set and if installed 
# via homebrew

[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/opt/groovy/libexec" ] \
    && export GROOVY_HOME=/usr/local/opt/groovy/libexec

# Not sure when homebrew groovy started to use that path, so fall back to lots
# and lots of alternates because I don't care enough to actually research this.

[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/Cellar/groovy/2.1.1/libexec" ] \
    && export GROOVY_HOME=/usr/local/Cellar/groovy/2.1.1/libexec

# Or try 2.1.0

[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/Cellar/groovy/2.1.0/libexec" ] \
    && export GROOVY_HOME=/usr/local/Cellar/groovy/2.1.0/libexec

# Or try 2.0.0

[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/Cellar/groovy/2.0.1/libexec" ] \
    && export GROOVY_HOME=/usr/local/Cellar/groovy/2.0.1/libexec

# Or try 2.0.0

[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/Cellar/groovy/2.0.0/libexec" ] \
    && export GROOVY_HOME=/usr/local/Cellar/groovy/2.0.0/libexec

# Or try 1.8.6

[ -z "$GROOVY_HOME" ] \
    && [ -d "/usr/local/Cellar/groovy/1.8.6/libexec" ] \
    && export GROOVY_HOME=/usr/local/Cellar/groovy/1.8.6/libexec


