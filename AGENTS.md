# AGENTS.md - Dotfiles Assistant Context

This repository powers macOS dotfiles that rely on OpenAI-powered agents (exposed via the `codex` CLI) for assisted coding, automation, and quick experiments. The overall layout and workflows mirror the rest of the dotfiles project, but interactions assume GPT-style semantics (structured tool usage, strict system instructions, JSON-friendly replies) rather than the more conversational defaults used by Claude.

## Repository Structure

- **Modular organization**: Each directory configures a specific tool or service
- **Install scripts**: `install.sh` scripts manage installation and setup
- **Zsh configuration**: `.zshrc` and `.0zshrc` files customize the shell runtime
- **Symlinks**: `.symlink` files are linked into `~/.filename` via rake tasks
- **Bootstrap**: `rake update` pulls, installs, links, and refreshes everything

## Key Workflows

### Installation & Updates
- Run `rake update` to sync the repo (git pull, brew update/upgrade, link symlinks, run install scripts)
- Run `rake install` to execute only the `install.sh` scripts
- Run `rake link` to create or refresh the symlinks

### Testing Changes
- Preferred test: run `rake` and confirm the run completes without errors
- Use git to revert experiments that do not pan out
- Treat edits to `install.sh` and `.zshrc` files with care—they impact every shell
- Shell scripts are checked with `shellcheck` during `rake update`
- Run `rake shellcheck` to lint scripts on demand
- Use `.shellcheckignore` to exclude vendored or third-party code from linting
- Third-party directories remain untouched to keep upstream updates simple

### Environment Management Priority
Keeping nvm, poetry, Homebrew, and other managers aligned is the primary challenge. Focus on:

- **PATH composition**: Ensure each tool adds its segments without clobbering others
- **Node.js/npm**: Uses nvm with per-tool version pinning when needed
- **Global access**: CLI commands like `codex` should work regardless of local project configuration
- **Isolation**: Keep each tool's env setup self-contained to avoid cross-contamination

## Platform Assumptions

- **OS**: macOS
- **Package manager**: Homebrew
- **Terminal**: iTerm2
- **IDEs**: JetBrains (primary), with some Emacs and VS Code usage
- **Shell**: zsh

## Zsh Configuration System

1. **Bootstrap order**: `.0zshrc` files initialize before `.zshrc`
2. **Global sourcing**: All `*/*.zshrc` files are sourced automatically
3. **Local hooks**: `~/.prerc` (pre) and `~/.localrc` (post) allow machine-specific tweaks
4. **PATH assembly**: Multiple directories contribute PATH fragments; verify the final order

## Common Tasks

1. **Adding new tools**: Create a dedicated directory with an `install.sh` and supporting configs
2. **Debugging environments**: Investigate PATH conflicts or mismatched tool versions
3. **Managing symlinks**: Validate that link targets exist and do not collide
4. **Performance tuning**: Profile shell startup with `env DEBUG=1 ZSH_PROF= zsh -ic zprof`

## Special Considerations

### Node.js & Codex CLI
- `codex` command is installed globally via `npm install -g @openai/codex`
- The install script invokes `nvm install`; provide a `.nvmrc` when pinning versions
- Ensure the CLI is reachable even when a project-specific `.nvmrc` selects another Node version (`nvm-exec` handles isolation)
- GPT-style assistants honor system instructions strictly; confirm prompts include necessary guardrails (JSON schema, tools, etc.)

### Prompt & Tool Semantics
- Prefer explicit instructions on output format; GPT responses follow structured formats more literally than Claude
- When requesting multi-step actions, specify ordering—GPT agents will not infer intent from context as readily
- Tool calls (shell, editing) should be scoped narrowly; GPT agents default to minimal side effects unless instructed otherwise
- Provide grounding context (file paths, command expectations) to minimize hallucinated details

### Tool Integration
- Each tool should own its PATH additions; avoid putting agent-specific paths in global profiles
- Keep OpenAI API credentials isolated (e.g., `.codexrc` or keychain) and out of version control
- Confirm upgrades do not regress CLI behaviour; breaking changes in the OpenAI API surface quickly in GPT-based tooling

## Maintenance Philosophy

- **Incremental changes**: Ship small, verifiable adjustments
- **Version control safety**: Lean on git for experiments and rollback
- **Keep it simple**: Choose the least complex solution that solves the problem
- **Tool harmony**: Ensure agent tooling coexists cleanly with other environment managers

## When Making Changes

1. Study existing tool directories for patterns before introducing new files
2. Follow established `install.sh` and `.zshrc` conventions
3. Run `rake` after modifications to validate the full toolchain
4. Audit PATH and environment variables for conflicts or unintended overrides
5. Verify that updates preserve existing integrations and agent workflows
