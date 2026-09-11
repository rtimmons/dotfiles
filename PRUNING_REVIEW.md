# Dotfiles pruning review

Source inventory for `feedback.py`. Run `venv/bin/python3 feedback.py` to review
directories; decisions and research requests are stored in `response.sqlite3`.

## Evidence and caveats

- Shell evidence comes from 5,139 `~/.zsh_history` lines dated 2024-11-21
  through 2026-08-29. Counts are command-line matches, not a complete activity
  log.
- GUI apps, shell hooks, aliases, and commands launched from other tools are
  undercounted. Installed apps and commands are supporting signals only.
- Git dates indicate maintenance, not use. Many installers were mechanically
  modernized in 2026.

## Recommended keep

These are active, foundational, or used indirectly often enough to earn their
place at the repo root.

| Confirm | Directory | What it adds | Evidence / note |
|---|---|---|---|
| [ ] | `001-lib` | Shared shell/install helpers and coreutils | Required by the loading and install model. |
| [ ] | `010-homebrew` | Homebrew environment and global update policy | `brew` appeared 67 times; `just` appeared 429 times. |
| [ ] | `020-mise` | Node/npm version management | Three Node versions and npm are installed; 13 history matches, last 2026-07-24. |
| [ ] | `050-pyenv` | Python version management | Three Python versions installed; 11 matches, plus 71 Python/pip commands. |
| [ ] | `060-virtualenv` | `ve`/`venv` helpers and virtualenv install | Helpers appeared 7 times; Python use is substantial. Keep, but simplify the global `~/venv` behavior later. |
| [ ] | `1password` | CLI, SSH agent, and `1pw-export` | App and CLI installed; 4 matches, last 2026-08-25. |
| [ ] | `atuin` | Transparent interactive history integration | Installed and sourced automatically; direct history is not expected. |
| [ ] | `bash` | Minimal fallback Bash config | Its symlink is active; low maintenance cost. |
| [ ] | `bat` | Replaces `cat` and adds Markdown-aware viewing | `cat` appeared 24 times, last 2026-07-19; `bat` is installed. |
| [ ] | `bin` | Personal command collection and PATH entry | Keep the container, but prune its contents separately; see below. |
| [ ] | `broot` | Tree navigation and `br` launcher | 46 matches, including 2026-08-29. |
| [ ] | `claude` | Claude Code install/wrapper and local skills | 24 matches, last 2026-04-26. |
| [ ] | `codex` | Codex CLI install and wrapper | 188 matches, including 2026-08-29. |
| [ ] | `diff-so-fancy` | Git diff presentation | Installed and wired into Git; direct invocation is not expected. |
| [ ] | `direnv` | Automatic per-directory environment loading | Installed and hooked automatically; direct invocation is not expected. |
| [ ] | `fd` | Fast file finder | Installed; one direct match, and it is a broadly useful primitive. |
| [ ] | `firefox` | Firefox profile CSS linking | Firefox is installed and both profiles link to the managed CSS; GUI use is not represented in history. |
| [ ] | `fonts` | Inconsolata LGC Nerd Font | The managed iTerm preferences explicitly select this font. |
| [ ] | `fzf` | Fuzzy finder shell integration | Installed; likely indirect/keybinding use despite no direct match. |
| [ ] | `git` | Git config, aliases, ignore rules, and Git tools | 2,208 Git/alias matches; core workflow. |
| [ ] | `github` | GitHub CLI | 5 matches, last 2026-08-11. |
| [ ] | `go` | Go toolchain and GOPATH setup | 16 matches, last 2026-03-30; also installs `tailcat`. |
| [ ] | `grep` | Grep color and convenience aliases | Foundational shell behavior with negligible maintenance. |
| [ ] | `hammerspoon` | Window-management automation | App installed; the config is tied to the Keychron layout but is no longer linked. |
| [ ] | `home-assistant` | Isolated Home Assistant CLI | 10 matches, last 2025-11-25; still a specialized live workflow. |
| [ ] | `iterm` | iTerm preferences and shell integration | App installed; 6 explicit matches and active font/config references. |
| [ ] | `keychron-q11` | Current keyboard mappings and automatic load | Recent 2026 config; `vitaly` is installed. |
| [ ] | `localcode` | Local LLM server/front-end orchestration | 16 matches, last 2026-08-26; most recently changed concern. |
| [ ] | `make` | Parallel make default | `make` appeared 17 times, last 2026-08-19. Consider deriving jobs from CPU count later. |
| [ ] | `most` | Default pager | Installed and exported globally; 2 direct matches undercount pager use. |
| [ ] | `opencode` | OpenCode install | 13 matches, last 2026-08-21; also used by `localcode`. |
| [ ] | `podman` | Container CLI plus lazy machine startup | 14 matches, last 2026-08-05. |
| [ ] | `proj` | Project navigation/inspection tooling | `proj` appeared 178 times, including 2026-08-29. |
| [ ] | `python` | Python environment defaults and packages | 71 Python/pip matches; complements `pyenv`. |
| [ ] | `qrdecode` | Custom QR-code decoder | Used twice on 2025-12-31; small, focused, and backed by an installed dependency. |
| [ ] | `readline` | Shared REPL keybindings/completion behavior | Symlink is active and benefits multiple tools indirectly. |
| [ ] | `ripgrep` | `rg` install and `frg` helper | Installed and foundational even though history records only one direct `rg` match. |
| [ ] | `ruby` | rbenv, defaults, and Ruby config | Two Ruby versions are installed and three config symlinks are active; keep unless both versions are obsolete. |
| [ ] | `rust` | Cargo binary PATH | Needed by the installed `vitaly` keyboard tool; tiny shell-only concern. |
| [ ] | `shellcheck` | Shell lint dependency | `just shellcheck` makes it part of the normal repo validation path. |
| [ ] | `sublimetext` | Active editor settings, snippets, and `subl`/`mate` wrappers | App installed; wrapper commands account for about 92 matches, last 2026-08-26. |
| [ ] | `tailcat` | Tailscale log viewer | Added 2026-08-26 and used once that day; give it a trial period. |
| [ ] | `terminal-notifier` | `notify` wrapper and notification binary | Used indirectly by `whisper`; direct history is not expected. |
| [ ] | `tldr` | Concise command help | 4 matches, last 2026-06-28. |
| [ ] | `whisper` | Voice Memo transcription/summarization pipeline | 4 matches and substantial recent custom work; active launch-agent workflow. |
| [ ] | `zsh` | Core interactive shell configuration | Central loader, prompt, history, completion, aliases, and functions. |
| [ ] | `zsh-highlighting` | Interactive syntax highlighting | Installed and loaded automatically; direct history is not expected. |

## Recommended icebox

These have strong evidence of being obsolete, superseded, empty, or speculative.
“Icebox” means preserve in Git under `icebox/<name>` until confidence is high.

| Confirm | Directory | What it adds | Why icebox |
|---|---|---|---|
| [ ] | `070-pipx` | pipx installer | No history matches and `pipx list` is empty. |
| [ ] | `KeyRemap4MacBook` | Pre-Karabiner keyboard remapping | Added in 2013; related app absent; superseded by `keychron-q11` and Hammerspoon. |
| [ ] | `asdf` | Another runtime manager | No plugins or versions installed; one match; superseded by `mise`/`pyenv`/`rbenv`. |
| [ ] | `auggie` | Augment Code CLI | Not currently available; 5 matches ending 2026-01-01; Codex/Claude are active. |
| [ ] | `autojump` | Directory jumping hook | Not installed, no matches; `broot` and `proj` are active. |
| [ ] | `blot` | Blot blog publishing helper | No matches; unchanged since 2018 and contains an old blog URL/workflow. |
| [ ] | `comby` | Structural code search tool | Installed but no history matches; appears speculative. |
| [ ] | `devbox` | Devbox/Nix PATH and setup notes | Not installed, no matches, stale since 2022; setup file contains one-off machine surgery. |
| [ ] | `fish` | Fish migration proposal only | No implementation; a speculative planning document rather than live config. |
| [ ] | `fman` | fman PATH | App absent, no matches. |
| [ ] | `fortune` | `strategy` function and cloned quote data | No `fortune` or `strategy` matches; installer performs a Git clone. |
| [ ] | `gradle` | Gradle aliases | Gradle absent, no matches, unchanged since 2015. |
| [ ] | `grc` | Coreutils-backed `ls` aliases | `grc` itself is absent and unused. Move the useful `ls` aliases into `zsh` first. |
| [ ] | `groovy` | `GROOVY_HOME` | Groovy absent, no matches. |
| [ ] | `heroku` | Heroku CLI | Installed but no matches in 21 months of history. |
| [ ] | `hexyl` | Hex viewer | Installed but no matches; system hex tools already exist. |
| [ ] | `html2text` | Legacy html2text formatting config | Command absent; symlink is still active; file dates to 2012. |
| [ ] | `hub` | Legacy GitHub CLI | Installed but unused; superseded by active `gh`. |
| [ ] | `jenv` | Java version-manager hook | Tool absent, no matches. |
| [ ] | `jnl` | PATH/alias for a separate journal project | Target command absent, no matches, unchanged since 2019. |
| [ ] | `micro` | Locally downloaded editor binary | Binary absent, no matches; curl-pipe installer is unnecessary. |
| [ ] | `mono` | Mono environment variable | Mono absent, no matches. |
| [ ] | `poetry` | Old Poetry activation hook | Poetry absent, no matches; uses Poetry's retired installer layout. |
| [ ] | `qalculate-gtk` | GUI/CLI calculator | Installed but no history matches. |
| [ ] | `screen` | GNU Screen config | Config literally says it is untested/not used; no matches. |
| [ ] | `slate` | Old window manager config | Slate app absent and the config has no active symlink. |
| [ ] | `smlnj` | Standard ML PATH | Tool absent, no matches. |
| [ ] | `terminal-dot-app` | Apple Terminal theme notes | iTerm is the active managed terminal; unchanged since 2018. |
| [ ] | `texlive` | Empty compatibility PATH fragment | Explicitly says `mactex` replaced it; safe to delete after a short icebox period. |
| [ ] | `textedit` | `txt` alias | No matches. |
| [ ] | `vim` | Old speculative Vim config | No matches; README says “considering switching”; config has no active symlink. |
| [ ] | `windsurf` | Windsurf PATH | App and command absent, no matches. |
| [ ] | `x11` | Old Xterm preferences | XQuartz/xterm absent; config has no active symlink; unchanged since 2012. |
| [ ] | `yarn` | Legacy global Yarn PATH | Yarn absent; 5 matches, all ending 2024-12-21; Node work now uses `mise`/npm. |

## Initial manual review

These have mixed signals. The text after each checkbox is the specific question
to answer.

| Decide | Directory | What it adds | Question / leaning |
|---|---|---|---|
| [ ] | `as-ascii` | Tiny custom binary-data visualizer | Used twice, last 2025-10-18. **Lean icebox:** would `xxd`/`hexdump` be enough? |
| [ ] | `awscli` | AWS aliases and local credential config hook | 5 matches, last 2025-08-19. Keep only if AWS remains an occasional real workflow. |
| [ ] | `cursor` | Cursor agent CLI and alias | `cursor-agent` is installed and one related command appeared 2026-08-22, but Cursor.app is absent. Keep for the CLI or icebox? |
| [ ] | `de-chat` | Converts Claude terminal output to plain GFM | Recent custom tool with tests, but no history matches. Is it used through a pipe/script that history misses? |
| [ ] | `emacs` | Emacs, Prelude checkout, personal config, and symlink | App installed, but only 5 matches ending 2025-03-19. **Lean icebox:** its installer fetches and hard-resets Prelude on every install run. |
| [ ] | `jetbrains-toolbox` | Toolbox-generated launcher PATH | Toolbox app is installed; shell history cannot identify IDE GUI use. Do you launch JetBrains tools from the shell? |
| [ ] | `lm-studio` | LM Studio CLI PATH | App installed, but no CLI evidence; `localcode` now uses other backends. Still used? |
| [ ] | `mactex` | TeX distribution and versioned PATH | `pdflatex`/`xelatex` are installed but never appear in history. Keep only with `merdoc` PDF or other TeX work? |
| [ ] | `merdoc` | Custom Markdown/Mermaid to HTML/PDF tool | Updated 2026-07-02 and installed, but no command matches. Was this completed for real use or exploratory? |
| [ ] | `osx` | Manual macOS defaults and startup-chime scripts | Not auto-run and therefore low burden, but much of `defaults.sh` is old and version-sensitive. Refresh or icebox? |
| [ ] | `perl` | Local Perl library environment and modules | Only 3 matches, last 2024-11-21; still supports old `bin`/TextMate material. Decide together with those. |
| [ ] | `textmate` | TextMate bundles, commands, themes, and `.tm_properties` | App installed but config is no longer linked; the 90 `mate` matches may be Sublime's compatibility wrapper. |
| [ ] | `units` | `units` with readline wrapper | No matches; tiny and harmless, but not earning a separate concern on observed use. |
| [ ] | `vscode` | VS Code settings link | App installed; 6 `code` matches ending 2025-12-16. Keep for occasional use or consolidate editor choices? |

## Local/generated directories

These are not tracked concerns and should not go into the Git icebox.

| Confirm | Directory | Recommendation |
|---|---|---|
| [ ] | `.claude` | Keep local. It contains only per-repo permission settings and is not tracked. |
| [ ] | `lib` | Delete locally; it is empty and untracked. |
| [ ] | `venv` | Delete or relocate after confirming `asciimol` is no longer needed. It is an ignored 63 MB Python 3.10 environment at repo root. |

## `bin` follow-up

Keep `bin` itself because it is an effective home for small personal commands,
but treat it as a second pruning pass.

- Observed direct use: `cleanbash`, `cpanm`, `hosts.sh`, `ipwtf`, `mw`, `now`,
  `ps-port`, and `whichpp`.
- No direct history match: 39 other tracked commands. Some may be called by
  editor bundles or automation, so confirm references before moving them.
- Suggested shape: keep active commands directly in `bin/`; move uncertain ones
  to `bin/icebox/`, which naturally removes them from PATH without another
  manifest.

## Management recommendation

The one-directory-per-concern model remains worth keeping. Root placement is
the active manifest, while `icebox/` is the explicit inactive state; another
plugin manifest would duplicate that information. The active root now contains
44 installers and 56 shell fragments.

The remaining complexity is concentrated in heavy or stateful installers such
as Emacs/Prelude, Whisper models, and local LLM setup. Make those opt-in only if
routine `just update` runs become slow or surprising. Generated environments
are still better kept outside the checkout when they next need maintenance.
