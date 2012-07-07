autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi

for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
done

# see http://www.bigsoft.co.uk/blog/index.php/2008/04/11/configuring-ls_colors
# (set directories to be bold blue:)
export LS_COLORS="di=34;01"
export CLICOLOR=true
# see the man page for ls on such a system to figure this business out:
export LSCOLORS=Exfxcxdxbxegedabagacad
# support for dircolors if it exists:
[ -x "/usr/bin/dircolors" ] && eval "`/usr/bin/dircolors -b`"

