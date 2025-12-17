#!/usr/bin/env bash

# MacTeX installation script for dotfiles

set -e

echo "Checking MacTeX installation..."

# Check if MacTeX is already installed
if command -v pdflatex >/dev/null 2>&1 && command -v xelatex >/dev/null 2>&1; then
    echo "MacTeX is already installed"
    pdflatex --version | head -n1
    xelatex --version | head -n1
    echo "MacTeX installation complete"
    exit 0
fi

# Install MacTeX via Homebrew Cask
echo "Installing MacTeX via Homebrew..."
if command -v brew >/dev/null 2>&1; then
    brew install --cask mactex
    echo "MacTeX installed successfully"
    echo ""
    echo "Note: You may need to restart your terminal or run:"
    echo "  eval \"\$(/usr/libexec/path_helper)\""
    echo "to update your PATH for LaTeX commands."
else
    echo "Error: Homebrew not found. Please install Homebrew first."
    echo "Visit: https://brew.sh"
    exit 1
fi
