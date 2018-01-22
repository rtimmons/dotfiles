#!/usr/bin/env zsh

cd "$(dirname $0)"

POWERLINE_CONFIG_PATHS=(
    "$ZSH/powerline/config"
)

py_home="$(pyenv prefix)"
# echo "py_home = $py_home"
add_to_path "$py_home"/bin

powerline-daemon -q

source "$py_home"/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh

unset py_home

if [ -e "$ZSH/powerline/powerlevel9k" ]; then
    # https://github.com/bhilburn/powerlevel9k/wiki/Show-Off-Your-Config
    # https://github.com/bhilburn/powerlevel9k
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=( )
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status vcs virtualenv pyenv aws dir)
    source "$ZSH/powerline/powerlevel9k/powerlevel9k.zsh-theme"
fi