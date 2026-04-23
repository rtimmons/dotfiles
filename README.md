dotfiles
========

macOS dotfiles for shell setup, tool installs, and symlinked config.

Bootstrap
---------

```bash
cd ~/Projects
git clone --recursive https://github.com/rtimmons/dotfiles.git
cd dotfiles
just update
```

Key Commands
------------

```bash
just update      # pull, brew update/upgrade, link symlinks, run installs, shellcheck
just install     # run install.sh scripts only
just link        # refresh symlinks only
just shellcheck  # lint managed shell scripts
```

Layout
------

- Each top-level directory owns one tool or concern.
- `install.sh` scripts must stay silent on success.
- `*.symlink` files are linked into `~/.*`.
- `*.0zshrc` files load before `*.zshrc` files.
- `~/.prerc` loads before repo zsh config and `~/.localrc` loads after it.

Notes
-----

- Test changes with `just` when the change is safe to run end to end.
- Use `command -v <cmd> >/dev/null 2>&1` for command existence checks.
- Keep tool-specific PATH changes local to the tool that needs them.
