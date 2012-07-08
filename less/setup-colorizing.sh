#!/bin/zsh

# http://stackoverflow.com/questions/4324558/whats-the-proper-way-to-install-pip-virtualenv-and-distribute-for-python

# Use this to install syntax highlighting in less

if [[ "$1" = "remove" ]]; then
    echo "Uninstalling less syntax highlighting"
    rm -rf "lesspipe.sh" py-env0
    exit 0
fi

# Select current version of virtualenv:
VERSION=1.6.4
# Name your first "bootstrap" environment:
INITIAL_ENV=py-env0
# Options for your first environment:
ENV_OPTS='--no-site-packages --distribute'
# Set to whatever python interpreter you want for your first environment:
PYTHON=$(which python)
URL_BASE=http://pypi.python.org/packages/source/v/virtualenv

# --- Real work starts here ---
curl -O $URL_BASE/virtualenv-$VERSION.tar.gz
tar xzf virtualenv-$VERSION.tar.gz
# Create the first "bootstrap" environment.
eval $PYTHON virtualenv-$VERSION/virtualenv.py $ENV_OPTS $INITIAL_ENV
# Don't need this anymore.
rm -rf virtualenv-$VERSION
# Install virtualenv into the environment.
$INITIAL_ENV/bin/pip install virtualenv-$VERSION.tar.gz

rm "virtualenv-$VERSION.tar.gz"

chmod +x "./$INITIAL_ENV/bin/activate"
"./$INITIAL_ENV/bin/activate"

"$ZSH/less/py-env0/bin/easy_install" pygments

{
    cat <<-EOS
#!/bin/sh
case "$1" in
   # add all extensions you want to handle here
   *.awk|*.groff|*.java|*.js|*.m4|*.php|*.pl|*.pm|*.pod|*.sh|\
   *.ad[asb]|*.asm|*.inc|*.[ch]|*.[ch]pp|*.[ch]xx|*.cc|*.hh|\
   *.lsp|*.l|*.pas|*.p|*.xml|*.xps|*.xsl|*.axp|*.ppd|*.pov|\
   *.diff|*.patch|*.py|*.rb|*.sql|*.ebuild|*.eclass)
      $ZSH/less/py-env0/bin/pygmentize "$1" ;;
   *) exit 0;;
esac
EOS
} > "$ZSH/less/lesspipe.sh"

chmod +x "$ZSH/less/lesspipe.sh"
