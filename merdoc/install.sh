#!/usr/bin/env bash
set -euo pipefail

# Source the install library for helper functions
if [[ -f "$ZSH/001-lib/install-lib.sh" ]]; then
    # shellcheck source=../001-lib/install-lib.sh
    # shellcheck disable=SC1091
    source "$ZSH/001-lib/install-lib.sh"
fi

# Install pandoc via homebrew
brew_install pandoc

# Install fswatch for watch functionality
brew_install fswatch

# Create Python virtual environment for live reload functionality
if command -v python3 >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    VENV_DIR="$SCRIPT_DIR/venv"

    if [[ ! -d "$VENV_DIR" ]]; then
        echo "Creating Python virtual environment for live reload..."
        python3 -m venv "$VENV_DIR" || {
            echo "Warning: Could not create virtual environment. Live reload may not work."
            exit 0
        }
    fi

    # Install websockets library in the virtual environment
    if [[ -f "$VENV_DIR/bin/python" ]]; then
        echo "Installing websockets library in virtual environment..."
        "$VENV_DIR/bin/python" -m pip install --upgrade pip >/dev/null 2>&1
        "$VENV_DIR/bin/python" -m pip install websockets >/dev/null 2>&1 || {
            echo "Warning: Could not install websockets library. Live reload may not work."
        }
    fi
fi

# Install LaTeX (MacTeX) for PDF generation (optional but recommended)
# This is a large download (~4GB), so it's optional
if command -v pdflatex >/dev/null 2>&1; then
    echo "LaTeX already installed"
else
    echo "Installing MacTeX for PDF generation..."
    echo "Note: This is a large download (~4GB). You can skip this and use HTML-only mode."
    read -p "Install MacTeX? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew_install --cask mactex
    else
        echo "Skipping MacTeX installation. You can install it later with: brew install --cask mactex"
    fi
fi

# Install mermaid CLI via npm (requires node/npm)
# First ensure we have the desired node version
ensure_desired_node "$(dirname "$0")"

# Install mermaid CLI globally
if ! command -v mmdc >/dev/null 2>&1; then
    echo "Installing mermaid CLI..."
    npm install -g @mermaid-js/mermaid-cli
fi

# Create bin directory if it doesn't exist
mkdir -p "$(dirname "$0")/bin"

# Download the pandoc diagram filter
filter_dir="$(dirname "$0")/pandoc-ext-diagram"
if [[ ! -d "$filter_dir" ]]; then
    echo "Downloading pandoc diagram filter..."
    git clone --depth 1 https://github.com/pandoc-ext/diagram.git "$filter_dir"
fi

echo "merdoc installation complete"
echo ""
echo "For PDF generation, merdoc uses xelatex (preferred) or lualatex for better Unicode support."
echo "If you just installed MacTeX, you may need to restart your terminal"
echo "or run 'eval \"\$(/usr/libexec/path_helper)\"' to update your PATH for LaTeX commands."