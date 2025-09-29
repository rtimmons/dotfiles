# Dotfiles Project Board

This file serves as a kanban-style project board for tracking TODO items, code hygiene issues, and improvement opportunities in the dotfiles repository.

## 🔴 Critical Issues

*No critical issues remaining*

## 🟡 In Progress

*No items currently in progress*

## 🟢 Ready to Start

### Fix Proj Function Export
- **Status**: `ready`
- **Priority**: `medium`
- **Category**: `code-quality`
- **Estimate**: `15m`
- **Files**: `zsh/functions/proj:3`
- **Dependencies**: None

Make `__proj_gothere()` not exported to shell namespace to avoid pollution.

### Enhance Proj Function Matching
- **Status**: `ready`
- **Priority**: `low`
- **Category**: `enhancement`
- **Estimate**: `1h`
- **Files**: `zsh/functions/proj:59`
- **Dependencies**: None

Allow more flexible matching with suggested Perl implementation.

### Clean Up README TODO Section
- **Status**: `ready`
- **Priority**: `medium`
- **Category**: `documentation`
- **Estimate**: `1h`
- **Files**: `README.md:38-172`
- **Dependencies**: None

Large TODO section needs review, cleanup, and organization.

### Monitor Shell Startup Performance
- **Status**: `ready`
- **Priority**: `low`
- **Category**: `performance`
- **Estimate**: `30m`
- **Files**: Various zsh configs
- **Dependencies**: None

Use `env DEBUG=1 ZSH_PROF= zsh -ic zprof` to identify performance bottlenecks.
Also see https://scottspence.com/posts/speeding-up-my-zsh-shell.

### Configure File Completion Fallback
- **Status**: `ready`
- **Priority**: `low`
- **Category**: `enhancement`
- **Estimate**: `45m`
- **Files**: Zsh completion configs
- **Dependencies**: None

Configure completion to complete files when no other completion is applicable.

## 🔵 Backlog

### Explore jj Version Control System
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-evaluation`
- **Estimate**: `2h`
- **Added**: `2025-01-22`
- **URL**: https://github.com/jj-vcs/jj
- **Dependencies**: None

Evaluate jj as git alternative for improved version control workflow.

### Add Z Plugin from Oh My Zsh
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `enhancement`
- **Estimate**: `1h`
- **Added**: `2023-01-27`
- **URL**: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/z
- **Dependencies**: None

Directory jumping based on frecency for improved navigation.

### Evaluate Difftastic
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-evaluation`
- **Estimate**: `1h`
- **Added**: `2022-10-07`
- **URL**: https://www.wilfred.me.uk/blog/2022/09/06/difftastic-the-fantastic-diff/
- **Dependencies**: None

Structural diff tool that understands syntax for better diff viewing.

### Add Tere File Browser
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-evaluation`
- **Estimate**: `1h`
- **Added**: `2022-07-15`
- **URL**: https://github.com/mgunyho/tere
- **Dependencies**: fzf

Terminal file browser for enhanced fzf-based file navigation.

### Install Git Toolbelt
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `tool-addition`
- **Estimate**: `30m`
- **Added**: `2022-07-05`
- **URL**: https://github.com/nvie/git-toolbelt
- **Dependencies**: None

Collection of useful git commands for improved git workflow.

### Add Redo Dynamic Aliases
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-evaluation`
- **Estimate**: `45m`
- **Added**: `2022-04-01`
- **URL**: https://github.com/barthr/redo
- **Dependencies**: None

Dynamic alias system for command re-execution with modifications.

### Replace diff-so-fancy with Delta
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `tool-replacement`
- **Estimate**: `1h`
- **Added**: `2021-05-03`
- **URL**: https://github.com/dandavison/delta
- **Dependencies**: None

Modern diff viewer with syntax highlighting and git integration.

### Add Git Branch Cleanup Tool
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `tool-addition`
- **Estimate**: `45m`
- **Added**: `2021-05-03`
- **URLs**: https://github.com/matt-harvey/git_curate, https://www.git-town.com/
- **Dependencies**: None

Tool for cleaning up merged/stale git branches (git curate or git town).

### Add entr File Watcher
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-addition`
- **Estimate**: `30m`
- **Added**: `2021-02-14`
- **URL**: https://eradman.com/entrproject/
- **Dependencies**: None

Run commands when files change for automated development workflows.

### Install Lazygit
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `tool-addition`
- **Estimate**: `30m`
- **Added**: `2020-05-30`
- **URL**: https://github.com/jesseduffield/lazygit
- **Dependencies**: None

Terminal UI for git commands with visual interface.

### Evaluate Fish Shell
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `shell-evaluation`
- **Estimate**: `4h`
- **Added**: `2019-11-12`
- **URL**: https://brettterpstra.com/2019/11/11/fish-further-exploration/
- **Dependencies**: None

Explore fish shell as alternative to zsh for improved defaults.

### Install Z Directory Jumper
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `tool-addition`
- **Estimate**: `30m`
- **Added**: `2019-11-01`
- **URL**: https://github.com/rupa/z
- **Dependencies**: None

Frecency-based directory jumping for faster navigation.

### Add Pro Git Repository Manager
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-evaluation`
- **Estimate**: `1h`
- **Added**: `2019-08-04`
- **URL**: https://github.com/trishume/pro
- **Dependencies**: None

Tool for managing multiple git repositories efficiently.

### Evaluate Z.lua Alternative
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-evaluation`
- **Estimate**: `1h`
- **Added**: `2019-02-04`
- **URL**: https://news.ycombinator.com/item?id=19077891
- **Dependencies**: None

Lua-based directory jumping alternative to z for performance.

### Enhance FZF Workflows
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `workflow-improvement`
- **Estimate**: `2h`
- **Added**: `2021-05-16`
- **URL**: https://seb.jambor.dev/posts/improving-shell-workflows-with-fzf/
- **Dependencies**: fzf

Implement advanced fzf workflows for improved shell productivity.

### Update macOS Defaults
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `system-configuration`
- **Estimate**: `2h`
- **Added**: `2021-04-15`
- **URL**: https://github.com/mathiasbynens/dotfiles/blob/master/.macos
- **Dependencies**: None

Review and update macOS system defaults based on latest recommendations.

### Add Finder-iTerm2 Integration
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `integration`
- **Estimate**: `45m`
- **Added**: `2020-11-17`
- **URL**: https://gist.github.com/pdanford/158d74e2026f393e953ed43ff8168ec1
- **Dependencies**: iTerm2

Seamless integration between Finder and iTerm2 for file operations.

### Evaluate NNN File Manager
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-evaluation`
- **Estimate**: `1h`
- **Added**: `2020-11-17`
- **URL**: https://news.ycombinator.com/item?id=25125137
- **Dependencies**: None

Terminal file manager for enhanced file browsing and operations.

### Implement CD Hooks (direnv)
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `workflow-improvement`
- **Estimate**: `2h`
- **Added**: `2019-07-29`
- **Dependencies**: None

Hook into cd command for automatic environment/tool activation.

### Enhance Proj Command
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `tool-enhancement`
- **Estimate**: `3h`
- **Added**: `2019-05-19`
- **Dependencies**: None

Sync Projects directories, check branches, generate status reports.

### Evaluate Homeshick
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-evaluation`
- **Estimate**: `2h`
- **Added**: `2018-12-26`
- **URL**: https://github.com/andsens/homeshick
- **Dependencies**: None

Git-based dotfiles synchronizer written in bash.

### Add Pipenv Integration
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-addition`
- **Estimate**: `1h`
- **Added**: `2018-02-22`
- **URL**: https://docs.pipenv.org/
- **Dependencies**: Python

Python package management alternative to pip + virtualenv.

### Create T Command for Timestamps
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `tool-creation`
- **Estimate**: `2h`
- **Added**: `2017-11-09`
- **Dependencies**: locutus

Natural language timestamp parsing command.

### Research Modern CLI Tools
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `research`
- **Estimate**: `3h`
- **Added**: `2017-10-12`
- **URLs**: https://dev.to/sobolevn/using-better-clis-6o8, https://dev.to/sobolevn/instant-100-command-line-productivity-boost
- **Dependencies**: None

Evaluate modern alternatives to traditional CLI tools.

## 📚 Research & Evaluation

### Zsh Framework Alternatives
- **Status**: `research`
- **Priority**: `low`
- **Category**: `framework-evaluation`
- **Estimate**: `4h`
- **Frameworks**: prezto, antigen, zim, zplug
- **Dependencies**: None

Evaluate alternatives to current zsh configuration approach.

### Enhanced CLI Tools
- **Status**: `research`
- **Priority**: `low`
- **Category**: `tool-research`
- **Estimate**: `2h`
- **Tools**: fzf, fzf-marks, zsh-history-substring-search, colorls, fasd
- **Dependencies**: Various

Research enhanced CLI tools for improved terminal experience.

### Configuration Enhancements
- **Status**: `research`
- **Priority**: `low`
- **Category**: `configuration`
- **Estimate**: `1h`
- **Items**: TextMate integration, NODE_PATH, LESSEDIT, zsh abbreviations, direnv, @nonrational git aliases
- **Dependencies**: Various

Research configuration improvements and integrations including git aliases from @nonrational's dotfiles.

### Reference Dotfiles Analysis
- **Status**: `research`
- **Priority**: `low`
- **Category**: `inspiration`
- **Estimate**: `2h`
- **Sources**: Various dotfiles repositories and zsh configurations
- **Dependencies**: None

Analyze other dotfiles for inspiration and best practices.

## 🔧 Code Quality Tasks

### Standardize Shell Scripts
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `code-quality`
- **Estimate**: `3h`
- **Files**: All shell scripts
- **Dependencies**: shellcheck

Fix remaining shellcheck warnings, standardize error handling and variable quoting.

### Optimize Zsh Configuration
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `performance`
- **Estimate**: `2h`
- **Files**: Zsh configuration files
- **Dependencies**: None

Review PATH building logic, optimize loading order, address performance implications.

### General Maintenance Tasks
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `maintenance`
- **Estimate**: `4h`
- **Files**: All configuration files
- **Dependencies**: None

Remove unused configurations, update tool versions, test install scripts, solidify shell conditionals.

### Improve Git Configuration
- **Status**: `backlog`
- **Priority**: `medium`
- **Category**: `configuration`
- **Estimate**: `1h`
- **Files**: `git/gitconfig.symlink`
- **Dependencies**: None

Use includes for work/personal separation, add more aliases and helpers.

### Update macOS System Settings
- **Status**: `backlog`
- **Priority**: `low`
- **Category**: `system-configuration`
- **Estimate**: `1h`
- **Dependencies**: None

Update proxy icon delay and other macOS defaults from latest recommendations.

## ✅ Completed

### Resolve Environment Management Conflicts - COMPLETED
- **Status**: `completed`
- **Priority**: `critical`
- **Category**: `environment`
- **Estimate**: `3h`
- **Files**: `001-lib/add_to_path.0zshrc`, `claude/env.zshrc`, `broot/env.zshrc`, `mactex/env.zshrc`, `texlive/path.zshrc`, `fzf/env.zshrc`, `jenv/env.zshrc`
- **Dependencies**: None
- **Completed**: `2025-06-15`

✅ **COMPLETED**: Resolved critical environment management conflicts:
- Enhanced `add_to_path` library with new `add_first_to_path()` function for version preference
- Fixed claude command wrapper to work without directory changes using NODE_VERSION
- Removed duplicate `$HOME/.cargo/bin` PATH addition from broot (kept in rust config)
- Consolidated TeX PATH management in mactex with version preference ordering
- Standardized PATH modifications to use `add_to_path()` function (fzf, jenv)
- Eliminated potential conflicts between different tool versions
- All tools now use consistent PATH management approach

### Standardize Command Existence Testing - COMPLETED
- **Status**: `completed`
- **Priority**: `high`
- **Category**: `code-quality`
- **Estimate**: `30m`
- **Files**: `050-pyenv/env.zshrc:4`, `050-pyenv/install.sh:5`, `060-virtualenv/install.sh:5`, `claude/install.sh:7`, `ruby/rbenv.zshrc:2`
- **Dependencies**: None
- **Completed**: `2025-06-15`

✅ **COMPLETED**: Standardized command existence testing across dotfiles:
- Replaced `which command` with POSIX-compliant `command -v command >/dev/null 2>&1`
- Fixed 5 files to use consistent pattern for portability
- Excluded third-party `emacs/prelude` directory from changes
- All command existence checks now follow consistent, portable pattern

### Fix Shell Script Issues (shellcheck) - COMPLETED
- **Status**: `completed`
- **Priority**: `critical`
- **Category**: `code-quality`
- **Estimate**: `2h`
- **Files**: `bin/cht.sh`, `asdf/install.sh`
- **Dependencies**: None
- **Completed**: `2025-06-15`

✅ **COMPLETED**: Fixed critical shellcheck warnings:
- bin/cht.sh: Fixed unused variables, deprecated x-prefix comparisons, printf format issues
- asdf/install.sh: Added shellcheck directive for external source
- Added `rake shellcheck` command to prevent future regressions
- All critical issues resolved, remaining issues are in other scripts

---

## Metadata for Pandoc Processing

This file uses consistent metadata fields for each task:
- **Status**: `todo`, `ready`, `in_progress`, `blocked`, `backlog`, `research`, `completed`
- **Priority**: `critical`, `high`, `medium`, `low`
- **Category**: `code-quality`, `environment`, `enhancement`, `tool-evaluation`, `documentation`, etc.
- **Estimate**: Time estimate in hours/minutes
- **Files**: Affected file paths with line numbers where applicable
- **Dependencies**: Required tools or other tasks
- **Added**: Date when item was added (for backlog items)
- **URL**: Reference links where applicable

*This project board consolidates all TODO items, code hygiene issues, and improvement opportunities found throughout the dotfiles repository.*