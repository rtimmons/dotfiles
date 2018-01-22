#!/bin/zsh

# http://stackoverflow.com/questions/4324558/whats-the-proper-way-to-install-pip-virtualenv-and-distribute-for-python

cd "$(dirname $0)"
if [ ! -d venv ]; then
    virtualenv venv
fi

source venv/bin/activate
pip install pygments

{
    cat <<-EOS
#!/bin/sh
case "\$1" in
    # add all extensions you want to handle here
    *.awk|*.groff|*.java|*.js|*.m4|*.php|*.pl|*.pm|*.pod|*.sh|\\
    *.ad[asb]|*.asm|*.inc|*.[ch]|*.[ch]pp|*.[ch]xx|*.cc|*.hh|\\
    *.md|\\
    *.lsp|*.l|*.pas|*.p|*.xml|*.xps|*.xsl|*.axp|*.ppd|*.pov|\\
    *.diff|*.patch|*.py|*.rb|*.sql|*.ebuild|*.eclass)
        $ZSH/less/venv/bin/pygmentize -O 'style=trac' "\$1" ;;
    *) exit 0;;
esac
EOS
} > "$ZSH/less/lesspipe.sh"

chmod +x "$ZSH/less/lesspipe.sh"

echo ""

echo "Successfully setup syntax highlighting for less."
echo "Reload zshrc or restart to take effect."
echo "Sample files in $ZSH/less/t"
