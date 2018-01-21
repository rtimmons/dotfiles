POWERLINE_CONFIG_PATHS=(
    "$ZSH/powerline/config"
)

py_home="$(pyenv prefix)"
add_to_path "$py_home"/bin

powerline-daemon -q

source "$py_home"/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh

unset py_home