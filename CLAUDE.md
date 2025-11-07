# CLAUDE.md - Dotfiles Assistant Context

This is a personal dotfiles repository for macOS that manages shell configuration, development tools, and environment setup.

## Repository Structure

- **Modular organization**: Each directory contains configs for a specific tool/service
- **Install scripts**: `install.sh` files handle tool installation and setup
- **Zsh configuration**: `.zshrc` and `.0zshrc` files for shell customization
- **Symlinks**: `.symlink` files are linked to `~/.filename` by rake
- **Bootstrap**: `rake update` pulls, installs, links, and updates everything

## Key Workflows

### Installation & Updates
- Run `rake update` to update everything (git pull, brew update/upgrade, link symlinks, run install scripts)
- Run `rake install` to only run install.sh scripts
- Run `rake link` to only create symlinks

### Testing Changes
- Primary test method: run `rake` and ensure nothing breaks
- Use git for rollback if issues occur
- Be careful with changes to `install.sh` and `.zshrc` files
- All shell scripts are validated with `shellcheck` as part of `rake update`
- Run `rake shellcheck` to manually check shell scripts for issues
- Use `.shellcheckignore` files to exclude third-party code from shellcheck (see `emacs/.shellcheckignore` example)
- Third-party directories like `emacs/prelude` are excluded from code quality maintenance to avoid modifying upstream code

### Environment Management Priority
The biggest challenge is keeping environment management tools (nvm, poetry, homebrew, etc.) working together without conflicts. Special attention needed for:

- **PATH management**: Tools should not interfere with each other
- **Node.js/npm**: Uses nvm with specific versions (see `.nvmrc` files)
- **Global tools**: Commands like `claude` should work regardless of local `.nvmrc` context
- **Tool isolation**: Each tool's environment should be self-contained

## Platform Assumptions

- **OS**: macOS
- **Package manager**: Homebrew
- **Terminal**: iTerm2
- **IDEs**: JetBrains IDEs (primary), some Emacs, some VS Code
- **Shell**: zsh

## Zsh Configuration System

1. **Bootstrap order**: `.0zshrc` files load before `.zshrc` files
2. **Global sourcing**: All `*/*.zshrc` files are automatically sourced
3. **Local hooks**: `~/.prerc` (before) and `~/.localrc` (after) for local customization
4. **PATH building**: Multiple tools contribute to PATH through their configs

## Common Tasks

1. **Adding new tools**: Create directory with `install.sh` and relevant config files
2. **Environment debugging**: Check PATH conflicts, tool version mismatches
3. **Symlink management**: Ensure proper linking without conflicts
4. **Performance optimization**: Monitor shell startup time (use `env DEBUG=1 ZSH_PROF= zsh -ic zprof`)

## Special Considerations

### Node.js & Claude CLI
- `claude` command installed globally via `npm install -g @anthropic-ai/claude-code`
- Uses nvm-exec to ensure consistent Node version (v22.12.0 per claude/.nvmrc)
- Should work regardless of local project's `.nvmrc` file

### Tool Integration
- Each tool should manage its own PATH additions
- Avoid global pollution of shell environment
- Prefer tool-specific configuration over global changes

## Maintenance Philosophy

- **Incremental changes**: Make small, testable changes
- **Git-based recovery**: Rely on version control for rollback
- **Minimal complexity**: Avoid over-engineering solutions
- **Tool harmony**: Ensure tools coexist without conflicts

## When Making Changes

1. Understand the existing pattern in similar tool directories
2. Follow the established install.sh and .zshrc patterns
3. Test with `rake` after changes
4. Check for PATH and environment variable conflicts
5. Ensure changes don't break existing tool integrations
6. **File formatting**: Remove trailing newlines from all files. Blank lines should be truly empty (no spaces or tabs). Add blank lines for visual clarity where appropriate, but ensure they contain no whitespace.