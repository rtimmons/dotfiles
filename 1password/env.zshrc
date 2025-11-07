#!/usr/bin/env zsh

# Shell function to export environment variables from 1Password notes with "ENV " prefix
# Usage: 1pw-export
# This will automatically export all matching variables into the current shell

1pw-export() {
    local script_path

    # Locate the script using $ZSH
    if [ -z "$ZSH" ]; then
        echo "Error: ZSH variable not set. This function requires the dotfiles ZSH variable." >&2
        return 1
    fi

    script_path="$ZSH/1password/bin/1pw-export"

    if [ ! -f "$script_path" ]; then
        echo "Error: 1pw-export script not found at $script_path" >&2
        return 1
    fi

    # Execute the script and eval its output to export the variables
    eval "$("$script_path")"
}