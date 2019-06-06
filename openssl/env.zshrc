# "should" use `$(brew --prefix openssl@1.1)` but `brew` is slow
# this is run at every shell startup
export OPENSSL_ROOT_DIR="/usr/local/opt/openssl@1.1"
