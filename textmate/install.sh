#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define paths
TEXTMATE_BUNDLES_DIR="$HOME/Library/Application Support/TextMate/Bundles"

# Bundle definitions
BUNDLES=(
    "RyBundle.tmbundle"
    "Themes.tmbundle"
    "Markdown (GitHub) Font Settings.tmbundle"
)

echo "TextMate 2 Bundle Setup"
echo "======================="
echo

# Create the TextMate Bundles directory if it doesn't exist
if [ ! -d "$TEXTMATE_BUNDLES_DIR" ]; then
    echo "Creating TextMate Bundles directory..."
    mkdir -p "$TEXTMATE_BUNDLES_DIR"
    echo -e "${GREEN}✓ Created: $TEXTMATE_BUNDLES_DIR${NC}"
else
    echo -e "${GREEN}✓ Directory exists: $TEXTMATE_BUNDLES_DIR${NC}"
fi
echo

# Function to setup a single bundle
setup_bundle() {
    local BUNDLE_NAME="$1"
    local BUNDLE_SOURCE="$SCRIPT_DIR/$BUNDLE_NAME"
    local BUNDLE_LINK="$TEXTMATE_BUNDLES_DIR/$BUNDLE_NAME"
    
    echo "Setting up $BUNDLE_NAME..."
    
    # Check if the bundle source exists
    if [ ! -d "$BUNDLE_SOURCE" ]; then
        echo -e "${RED}Error: Bundle not found at $BUNDLE_SOURCE${NC}"
        return 1
    fi
    
    # Check if a symlink or file already exists
    if [ -L "$BUNDLE_LINK" ]; then
        # It's a symlink
        CURRENT_TARGET=$(readlink "$BUNDLE_LINK")
        if [ "$CURRENT_TARGET" = "$BUNDLE_SOURCE" ]; then
            echo -e "${GREEN}✓ Bundle already correctly linked${NC}"
            echo "  Link: $BUNDLE_LINK"
            echo "  Target: $BUNDLE_SOURCE"
        else
            echo -e "${YELLOW}⚠ Existing symlink points to different location${NC}"
            echo "  Current target: $CURRENT_TARGET"
            echo "  New target: $BUNDLE_SOURCE"
            read -p "Replace existing symlink? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm "$BUNDLE_LINK"
                ln -s "$BUNDLE_SOURCE" "$BUNDLE_LINK"
                echo -e "${GREEN}✓ Symlink updated${NC}"
            else
                echo "Skipping symlink update"
            fi
        fi
    elif [ -e "$BUNDLE_LINK" ]; then
        # Something else exists at that path
        echo -e "${YELLOW}⚠ A file or directory already exists at $BUNDLE_LINK${NC}"
        echo "Please remove it manually if you want to create the symlink"
        return 1
    else
        # Nothing exists, create the symlink
        ln -s "$BUNDLE_SOURCE" "$BUNDLE_LINK"
        echo -e "${GREEN}✓ Created symlink${NC}"
        echo "  Link: $BUNDLE_LINK"
        echo "  Target: $BUNDLE_SOURCE"
    fi
    echo
}

# Setup each bundle
for BUNDLE in "${BUNDLES[@]}"; do
    setup_bundle "$BUNDLE"
done

echo
echo -e "${GREEN}Setup complete!${NC}"
echo
echo "Next steps:"
echo "  1. Quit TextMate completely (Cmd+Q)"
echo "  2. Restart TextMate"
echo "  3. Check the Bundles menu for 'RyBundle'"
echo "  4. Your theme overrides should be automatically applied"
echo
echo "If the bundles don't appear:"
echo "  - Clear the bundle cache:"
echo "    rm ~/Library/Caches/com.macromates.TextMate/BundlesIndex.binary"
echo "  - Restart TextMate again"
echo
echo "To verify installation:"
echo "  - Open TextMate → Preferences → Bundles"
echo "  - Look for 'RyBundle' and 'Themes' in the list"
echo "  - Or check Bundles menu in the menu bar"
