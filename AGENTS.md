# AGENTS.md

This repo contains macOS dotfiles managed with `just`, shell scripts, zsh config, and symlinked files.

Core Rules
----------

- Keep docs short and current. Do not add historical notes, bug journals, or future-planning boards.
- Each top-level directory should own one tool or concern.
- `install.sh` scripts must stay silent on success and print useful output only on failure.
- Leave third-party or vendored code alone unless the task explicitly requires it.
- Keep exactly one trailing newline at EOF. Blank lines must be empty.

Commands
--------

- `just update`: pull, Homebrew update/upgrade, relink, install, shellcheck
- `just install`: run `install.sh` scripts only
- `just link`: refresh symlinks
- `just shellcheck`: lint managed shell scripts

Config Model
------------

- `*.0zshrc` files load before `*.zshrc` files.
- `~/.prerc` loads before repo zsh config and `~/.localrc` loads after it.
- `*.symlink` files are linked into `~/.*`.
- Verify PATH ordering when changing environment setup.

Implementation Notes
--------------------

- Prefer existing patterns from neighboring tool directories.
- Use `command -v <cmd> >/dev/null 2>&1` for command existence checks.
- Node-based CLIs in this repo use per-tool wrappers rather than repo-wide Node PATH injection.
- Keep PATH changes local to the tool that needs them.
- Run `just` after changes when the change is safe to validate end to end; otherwise run the narrowest relevant check.
