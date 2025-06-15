# TODO

This file consolidates all TODO items, code hygiene issues, and improvement opportunities found throughout the dotfiles repository.

## High Priority

### Shell Script Issues (shellcheck)
- **bin/cht.sh**: Multiple shellcheck warnings including unused variables, deprecated x-prefix comparisons, and printf format string issues
- **asdf/install.sh**: Missing shellcheck source following warning
- Run `shellcheck **/*.sh` and fix all issues systematically

### Environment Management Conflicts
- Ensure Node.js/npm tools work properly with nvm across different project contexts
- Verify `claude` command availability regardless of local `.nvmrc` files
- Test PATH management across all tools to prevent conflicts

## Medium Priority

### Code TODOs
- **git/gitconfig.symlink:23**: Add more aliases from @nonrational's dotfiles
- **zsh/functions/proj:3**: Make `__proj_gothere()` not exported to shell namespace
- **zsh/functions/proj:59**: Allow more flexible matching (suggested Perl implementation included)

### Documentation & Organization
- **README.md**: Large TODO section (lines 38-172) needs review and cleanup
- Consider moving completed TODOs to separate archive section
- Update installation instructions if needed

### Tool Improvements
- **Shell Startup Performance**: Monitor with `env DEBUG=1 ZSH_PROF= zsh -ic zprof`
- **Completion**: Configure completion to complete files if no other completion applicable

## Low Priority

### Feature Requests from README
- **2025-01-22: jj** as git alternative: https://github.com/jj-vcs/jj
- **2023-01-27: z plugin** from ohmyzsh: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/z
- **2022-10-07: difftastic**: https://www.wilfred.me.uk/blog/2022/09/06/difftastic-the-fantastic-diff/
- **2022-07-15: tere** for fzf-file browsing: https://github.com/mgunyho/tere
- **2022-07-05: git-toolbelt**: https://github.com/nvie/git-toolbelt
- **2022-04-01: redo** for dynamic aliases: https://github.com/barthr/redo
- **2021-05-03: delta** as diff-so-fancy alternative: https://github.com/dandavison/delta
- **2021-05-03: git curate** for branch cleanup: https://github.com/matt-harvey/git_curate (or git town: https://www.git-town.com/index.html)
- **2021-02-14: entr(1)** for file watching: https://eradman.com/entrproject/
- **2020-05-30: lazygit**: https://github.com/jesseduffield/lazygit
- **2019-11-12: fish shell**: https://brettterpstra.com/2019/11/11/fish-further-exploration/
- **2019-11-01: z** (cd replacement): https://github.com/rupa/z - "Tracks your most used directories, based on 'frecency'."
- **2019-08-04: pro tool** for git repo management: https://github.com/trishume/pro
- **2019-02-04: z.lua** (cd alternative): https://news.ycombinator.com/item?id=19077891

### Additional Tools & Improvements
- **2021-05-16: Improving shell workflows with fzf**: https://seb.jambor.dev/posts/improving-shell-workflows-with-fzf/
- **2021-05-16: Linux Terminal Tools**: https://www.evernote.com/l/AAFlLIy06fBOf5ZSp9XLsHzhNf2NLOKvAwc
- **2021-04-19: Do more with fzf**: https://seb.jambor.dev/posts/improving-shell-workflows-with-fzf/
- **2021-04-15: Updated macOS defaults**: https://github.com/mathiasbynens/dotfiles/blob/master/.macos
- **2020-11-17: Finder<->iTerm2 integration**: https://gist.github.com/pdanford/158d74e2026f393e953ed43ff8168ec1
- **2020-11-17: nnn file manager**: https://news.ycombinator.com/item?id=25125137
- **2019-07-29: Hook into cd for common things (direnv?)** - example chpwd function included
- **2019-05-19: proj command** - sync Projects dirs, check branches, generate reports
- **2018-12-26: homeshick**: https://github.com/andsens/homeshick - "git dotfiles synchronizer written in bash"
- **2018-02-22: pipenv**: https://docs.pipenv.org/ as alternative to pip + virtualenv
- **2017-11-09: t command** for natural language timestamps using locutus
- **2017-10-12: Better CLIs**: https://dev.to/sobolevn/using-better-clis-6o8
- **2017-10-06: CLI productivity boost**: https://dev.to/sobolevn/instant-100-command-line-productivity-boost

### Framework & Plugin Exploration
- **prezto**: Zsh framework alternative
- **antigen**: Zsh plugin manager
- **fzf**: https://github.com/junegunn/fzf
- **fzf-marks**: https://github.com/urbainvaes/fzf-marks
- **zsh-history-substring-search**: https://github.com/zsh-users/zsh-history-substring-search
- **zim**: https://github.com/Eriner/zim
- **zplug**: http://zplug.sh
- **colorls**: https://github.com/athityakumar/colorls
- **fasd**: https://github.com/clvv/fasd

### Configuration Ideas
- **TextMate bundle** integration
- **NODE_PATH** export: `/usr/local/lib/node_modules:$NODE_PATH`
- **LESSEDIT** export: `mate -l %lm %f`
- **Zsh abbreviations**: http://hackerific.net/2009/01/23/zsh-abbreviations/
- **GNOME Emacs keybindings**: `gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"`
- **direnv** integration: https://direnv.net/

### Research Sources
- http://dotfiles.org/~_why/.zshrc
- http://dotfiles.org/~mental/.zshrc
- http://dotfiles.org/~coder_/.zshrc
- https://github.com/holman/dotfiles/blob/master/zsh/functions/_brew
- Grml zshrc: http://git.grml.org/?p=grml-etc-core.git;a=blob_plain;f=etc/zsh/zshrc;hb=HEAD
- https://github.com/coreyja/dotfiles/blob/master/.gitconfig#L94-L98
- https://github.com/dbradf/configfiles

### macOS Defaults
- **2022-04-04: Proxy icon**: `defaults write -g NSToolbarTitleViewRolloverDelay -float 0`
- Review and update macOS defaults from: https://github.com/mathiasbynens/dotfiles/blob/master/.macos

### Git Configuration
- Use includes for .gitconfig to avoid work/personal email conflicts
- Consider more aliases and helpers from various sources listed in README

## Code Quality

### Shell Script Standards
- Fix all shellcheck warnings across all shell scripts
- Standardize error handling and variable quoting
- Review and update script headers and documentation

### Zsh Configuration
- Review PATH building logic for conflicts
- Optimize loading order (`.0zshrc` vs `.zshrc` files)
- Consider performance implications of all sourced files

### General Maintenance
- Remove unused/obsolete configurations
- Update tool versions and installation methods
- Test all install scripts on clean system
- **Shell conditionals**: Solidify usage of `if which cmd > /dev/null; then` vs `$+commands[cmd]` (ref: http://www.zsh.org/mla/users/2011/msg00070.html)

## Completed Items Archive
- None yet - items will be moved here as they're completed

---

*This TODO.md file was generated by analyzing the entire dotfiles repository for TODO comments, shellcheck issues, and improvement opportunities.*