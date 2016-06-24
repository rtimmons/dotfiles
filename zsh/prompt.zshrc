# prompt
autoload -U promptinit
promptinit

POSTPROMPT=
if [[ ! -z "$show_shortname_in_prompt" && ! -z "$shortname" ]]; then
    POSTPROMPT=" @$FX[underline]$FG[242]$shortname%f$FX[no-underline]"
fi

PROMPT="%B%#%b "
RPROMPT="  %U%~%u$POSTPROMPT"

unset POSTPROMPT

# http://dotfiles.org/~_why/.zshrc
# prompt (if running screen, show window #)
if [ ! -z "$WINDOW" ]; then
    RPROMPT="  w$WINDOW:%U%~%u"
fi

# Put `DISABLE_AUTO_TITLE=true` in ~/.prerc to disable term-title stuff.
# (Termtitle stuff seems to be pretty expensive?)
# if [ -z "$DISABLE_AUTO_TITLE" ]; then
#
#     # format titles for screen and rxvt
#     title() {
#         # escape '%' chars in $1, make nonprintables visible
#         a=${(V)1//\%/\%\%}
#
#         # Truncate command, and join lines.
#         a=$(print -Pn "%40>...>$a" | tr -d "\n")
#
#         case $TERM in
#         screen)
#             print -Pn "\ek$a:$3\e\\"      # screen title (in ^A)
#           ;;
#         xterm*|rxvt)
#           print -Pn "\e]2;$2 | $a:$3\a" # plain xterm title
#           ;;
#         esac
#     }
#
#     # precmd is called just before the prompt is printed
#     precmd() {
#       title "zsh" "$USER@%m" "%55<...<%~"
#     }
#
#     # preexec is called just before any command line is executed
#     preexec() {
#       title "$1" "$USER@%m" "%35<...<%~"
#     }
#
# fi


# Simplifies prompt for easier copy/paste of terminal output
noprompt() {
    PS1='$ '
    RPROMPT=
}
