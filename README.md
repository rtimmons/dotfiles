dotfiles
========

    My dotfiles >> your dotfiles

I jumped the shark (er..the boat) and switched to zsh. While poking around I found [holman's dotfiles](https://github.com/holman/dotfiles) and decided to blatantly copy a lot of his stuff.

Urgent TODOs
------------

- sort `zshrc` files before sourcing them and put them in sensible order
- `install.sh` scripts to let dirs do compile-once things
- Replace `$+commands[FOO]` with `command -v FOO >/dev/null 2>&1`

Bootstrap
---------

    cd ~/Projects
    git clone --recursive https://github.com/rtimmons/dotfiles.git

(Can actually be cloned anywhere)

Local Configs
-------------

Be sure to see zsh/zshrc.symlink for details on how to set configuration that takes effect before/after configs in this project are executed.

.0zhrc?
-------

tl;dr:

> Everything ending in .0zshrc is sourced before everything ending in .zshrc

Everything in this repo that ends in `.zshrc` is sourced upon startup. (Check out `zsh/zshrc.symlink`.) Problem is there are bootstrap issues. Some things depend on other things. Apparently I can't pass a custom comparator into zsh's globbing, so it's impossible to, say, run everything in asciibetical order based on `basename` of the file. If it were, you could just name your files `000-prompt.zshrc` or whatever.


TODO
----

- 2017-10-12: check out https://dev.to/sobolevn/using-better-clis-6o8
- 2017-10-06: check out https://dev.to/sobolevn/instant-100-command-line-productivity-boost
- check out prezto
- check out antigen
- check out https://github.com/junegunn/fzf
- check out https://github.com/urbainvaes/fzf-marks
- check out https://github.com/zsh-users/zsh-history-substring-search
- check out https://github.com/Eriner/zim
- check out http://zplug.sh
- check out https://github.com/athityakumar/colorls
- should put my textmate bundle here
- ?? export `NODE_PATH="/usr/local/lib/node_modules:$NODE_PATH"`
- ?? export `LESSEDIT='mate -l %lm %f'`
- http://hackerific.net/2009/01/23/zsh-abbreviations/
- http://dotfiles.org/~_why/.zshrc
- http://dotfiles.org/~mental/.zshrc
- http://dotfiles.org/~coder_/.zshrc
- https://github.com/holman/dotfiles/blob/master/zsh/functions/_brew
- Oh my zsh
- Grml zshrc <http://git.grml.org/?p=grml-etc-core.git;a=blob_plain;f=etc/zsh/zshrc;hb=HEAD>
- https://github.com/clvv/fasd
- https://github.com/coreyja/dotfiles/blob/master/.gitconfig#L94-L98
- emacs foo
- eclipse stuff
- terminal.app
- use emacs keybindings in GNOME linux: `gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"`


```
  unalias run-help
  autoload run-help
  HELPDIR=/usr/local/share/zsh/help

❯ brew list | grep zsh
zsh-completions
zsh-history-substring-search
zsh-syntax-highlighting
```

```
# from corey
alias current-branch='git rev-parse --abbrev-ref HEAD'
org={github organization goes here}
function callit() {
    BRANCH_PREFIX=$(whoami)
    CURRENT=$(current-branch)
    BRANCH_NAME=$BRANCH_PREFIX/$CURRENT/$1
    REPO_NAME=$(basename `git rev-parse --show-toplevel`)
    git checkout -b $BRANCH_NAME
    git add -A
    git commit
    git push -u origin $BRANCH_NAME
    open https://github.com/$org/$REPO_NAME/compare/$CURRENT...$BRANCH_NAME?expand=1
}
```

Credits
-------

I've stolen almost everything here.  I usually put the original source URL in comments next to the stolen bits.  Please contact me if I've stolen something and you want it back.


