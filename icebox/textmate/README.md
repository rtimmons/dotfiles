# TextMate 2 RyBundle

Personal TextMate 2 bundle containing custom commands, snippets, macros, and preferences.

## Installation

### Automatic Setup

Run the setup script from the textmate directory:

```bash
./setup.sh
```

This script will:
- Create the necessary directories
- Set up symlinks for the included bundles (RyBundle, Themes, Markdown font overrides)
- Check for existing installations
- Provide instructions for reloading bundles

### Manual Setup

To manually install this bundle in TextMate 2, create a symlink in the TextMate support directory:

```bash
# Create the Bundles directory if it doesn't exist
mkdir -p "$HOME/Library/Application Support/TextMate/Bundles/"

# Create symlink to the bundle (run from the textmate directory)
ln -s "$PWD/RyBundle.tmbundle" \
    "$HOME/Library/Application Support/TextMate/Bundles/RyBundle.tmbundle"
```

After creating the symlink, restart TextMate or reload bundles (Bundles → Bundle Editor → Reload Bundles) to see the new bundle.

### Alternative Installation Methods

1. **Double-click**: You can also double-click the `RyBundle.tmbundle` directory to install it (this will copy it to `~/Library/Application Support/TextMate/Pristine Copy/Bundles/`)
2. **Drag and drop**: Drag the bundle to the TextMate application icon

### Bundle Directory Structure

TextMate 2 uses these directories for bundles:
- `~/Library/Application Support/TextMate/Bundles/` - User modifications and manually installed bundles
- `~/Library/Application Support/TextMate/Pristine Copy/Bundles/` - Bundles installed via double-click
- `~/Library/Application Support/TextMate/Managed/Bundles/` - Bundles installed via Preferences

**Note**: The symlink method is preferred for development as it allows you to edit the bundle directly in your dotfiles repository.

## Bundle Contents

- **Markdown (GitHub) Font Settings**: Delta bundle that removes proportional font overrides so global monospace preferences apply to Markdown files
- **Commands**: Custom text manipulation commands (CSV formatting, text decorators, etc.)
- **Snippets**: Code snippets for quick insertion
- **Macros**: Recorded macro actions
- **Preferences**: Editor preferences
- **Support Scripts**: Perl utilities for text processing

## Uninstallation

To remove the bundle:

```bash
rm "$HOME/Library/Application Support/TextMate/Bundles/RyBundle.tmbundle"
```
