# Fish Shell Migration Guide

This document outlines the transition path from zsh to fish shell for this dotfiles repository.

## Current Zsh Architecture Analysis

### Core Shell Configuration System
- **Bootstrap**: `zsh/zshrc.symlink` orchestrates loading of all config files
- **Two-phase loading**: `.0zshrc` files load first, then `.zshrc` files
- **Modular design**: Each tool has its own directory with `install.sh` and config files
- **PATH management**: Centralized via `add_to_path` function from `001-lib/add_to_path.0zshrc`
- **Local hooks**: `~/.prerc` (pre) and `~/.localrc` (post) for machine-specific customization

### Key Components to Migrate

#### 1. Shell Options & Configuration (`zsh/config.zshrc`)
- 50+ zsh-specific options (AUTO_CD, EXTENDED_HISTORY, etc.)
- History configuration (5000 entries, append mode)
- Completion system setup
- Locale settings (UTF-8)

#### 2. Aliases & Functions (`zsh/aliases.zshrc`, `zsh/functions/`)
- 40+ aliases for common operations
- Custom functions: `proj`, `cdt`, `cleanenv`, `myip`
- Directory navigation shortcuts
- macOS-specific aliases (`finder`, `f.`)

#### 3. Environment Management (Multiple `env.zshrc` files)
- **Node.js**: Complex nvm integration with lazy loading and multi-version support
- **Python**: pyenv, virtualenv, pipx integration
- **Ruby**: rbenv integration
- **Homebrew**: PATH and completion setup
- **Development tools**: 30+ tools with PATH/env setup

#### 4. Prompt & Terminal Integration
- iTerm2-specific prompt configuration
- Terminal title management
- Shell integration features

#### 5. Key Bindings (`zsh/keybindings.zshrc`)
- Emacs-style key bindings
- Custom navigation shortcuts
- History search integration (atuin)

## Fish Migration Strategy

### Phase 1: Core Shell Setup (Effort: Medium, Risk: Low)
1. **Create fish config structure**:
   - `fish/config.fish` (equivalent to zshrc.symlink)
   - `fish/functions/` directory for custom functions
   - `fish/conf.d/` for modular configuration

2. **Migrate basic configuration**:
   - Convert shell options to fish equivalents
   - Set up history configuration
   - Configure locale and basic environment

### Phase 2: Environment Management (Effort: High, Risk: Medium)
1. **PATH management**: Replace `add_to_path` with fish's `fish_add_to_user_paths`
2. **Tool integration**: Convert each `env.zshrc` to fish format
3. **Version managers**: 
   - Node.js: Use fish-nvm or native fish integration
   - Python: Convert pyenv integration
   - Ruby: Convert rbenv integration

### Phase 3: Functions & Aliases (Effort: Medium, Risk: Low)
1. **Convert aliases**: Fish uses different syntax but straightforward conversion
2. **Migrate functions**: Rewrite zsh functions in fish syntax
3. **Custom completions**: Leverage fish's superior completion system

### Phase 4: Advanced Features (Effort: High, Risk: High)
1. **Prompt customization**: Use fish's built-in prompt system or starship
2. **Key bindings**: Convert to fish key binding syntax
3. **Terminal integration**: Ensure iTerm2 features work correctly

## Effort & Risk Assessment

### Overall Effort: **High** (3-5 days of focused work)
- **Core migration**: 1 day
- **Environment setup**: 2-3 days (complex tool integrations)
- **Testing & refinement**: 1 day

### Risk Levels by Component:
- **Low Risk**: Aliases, basic functions, shell options
- **Medium Risk**: Environment management, PATH setup
- **High Risk**: Complex integrations (nvm lazy loading, pyenv), custom key bindings

### Critical Dependencies:
1. **Node.js ecosystem**: Complex nvm integration with multiple versions
2. **Python toolchain**: pyenv + virtualenv + pipx coordination
3. **Development workflow**: 30+ tools must work seamlessly
4. **Terminal features**: iTerm2 integration, prompt behavior

## Pros & Cons of Fish Migration

### Pros ✅
1. **Superior user experience**:
   - Syntax highlighting out of the box
   - Intelligent autosuggestions based on history
   - Tab completions that "just work" for most commands

2. **Modern shell features**:
   - Better scripting syntax (more readable than zsh)
   - Built-in web-based configuration interface
   - Excellent documentation and community

3. **Performance**:
   - Faster startup time (no complex zsh plugin loading)
   - Efficient completion system
   - Better memory usage

4. **Maintenance**:
   - Less configuration needed for basic features
   - More stable API (fewer breaking changes)
   - Better error messages and debugging

### Cons ❌
1. **POSIX compatibility**:
   - Not POSIX compliant (some scripts may break)
   - Different variable syntax (`$PATH` vs `$path`)
   - May require script modifications

2. **Ecosystem maturity**:
   - Fewer third-party plugins compared to zsh
   - Some tools may not have fish-specific integrations
   - Learning curve for existing zsh users

3. **Migration complexity**:
   - Complex environment management needs rewriting
   - Custom functions require syntax conversion
   - Potential for subtle behavioral differences

4. **Tool compatibility**:
   - Some development tools assume bash/zsh
   - CI/CD scripts may need updates
   - Potential issues with legacy tooling

## Functionality Changes

### Will Be Better 🚀
- **Autocompletion**: Fish's completion system is superior
- **Syntax highlighting**: Built-in, no plugins needed
- **History search**: More intuitive than current atuin setup
- **Configuration**: Web interface for easy customization
- **Error handling**: Better error messages and debugging

### Will Be Different ⚠️
- **Variable syntax**: `set` instead of `export`, different expansion
- **Scripting**: Different syntax for conditionals and loops
- **Globbing**: Different pattern matching behavior
- **Job control**: Different background job syntax

### Potential Losses 😞
- **Zsh-specific features**: Some advanced zsh features don't exist in fish
- **Plugin ecosystem**: Fewer available plugins
- **Muscle memory**: Need to relearn some command patterns
- **Script compatibility**: Some existing scripts may need modification

## Recommended Approach

### Option 1: Gradual Migration (Recommended)
1. Set up fish alongside zsh (don't replace immediately)
2. Migrate core functionality first
3. Test thoroughly with daily workflow
4. Switch default shell only after confidence is high

### Option 2: Parallel Development
1. Create complete fish configuration
2. Use `chsh` to switch between shells for testing
3. Maintain both configurations until fish is proven

### Option 3: Hybrid Approach
1. Use fish for interactive sessions
2. Keep zsh for scripting and automation
3. Gradually migrate scripts to fish-compatible versions

## Next Steps

1. **Create basic fish configuration** to test core functionality
2. **Identify critical workflows** that must work immediately
3. **Set up development environment** with fish to test daily usage
4. **Create migration scripts** to automate conversion where possible
5. **Document differences** encountered during migration

The migration is feasible but requires significant effort due to the complexity of the current environment management system. The benefits of fish's user experience improvements may justify the investment, especially given the modern macOS/iTerm2 target environment.
