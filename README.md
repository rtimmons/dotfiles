dotfiles
========

    My dotfiles >> your dotfiles

I jumped the shark (er..the boat) and switched to zsh. While poking around I found [holman's dotfiles](https://github.com/holman/dotfiles) and decided to blatantly copy a lot of his stuff.

Urgent TODOs
------------

- Replace `$+commands[FOO]` with `command -v FOO >/dev/null 2>&1`
- Figure out why we're slow: https://github.com/robbyrussell/oh-my-zsh/issues/5327

Bootstrap
---------

    cd ~/Projects
    git clone --recursive https://github.com/rtimmons/dotfiles.git
    rake update
    rake install

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

- 2019-11-01: `z` : a `cd` replacement
  https://github.com/rupa/z : "Tracks your most used directories, based on 'frecency'."

- 2019-08-04: check out `pro` tool to wrangle the git-repo soup that is my ~/Projects folder
  https://github.com/trishume/pro/blob/master/README.md

  > pro is a command to wrangle your git repositories. It includes features like instantly cd'ing to your git repos and getting a status overview, and running an arbitrary command in every git repo.

- 2019-07-29: hook into `cd` for common things

    ```sh
    function chpwd() {
        emulate -L zsh
        ls -a
    }
    ```

    <http://zsh.sourceforge.net/Doc/Release/Functions.html#Hook-Functions>
    <https://unix.stackexchange.com/questions/170279>

- 2019-05-19: `proj` command: way to keep `Projects` dirs "synced" (at least check that all branches are pushed and produce a report/summary that indicates which dirs are there and that they correspond to which branches etc.
- 2019-02-04: look into z.lua (`cd` alternative) mentioned here: https://news.ycombinator.com/item?id=19077891
- 2018-12-26: look into https://github.com/andsens/homeshick: "git dotfiles synchronizer written in bash"
- 2018-02-22: use includes for .gitconfig to avoid having work/personal email address checked in
- 2018-02-22: explore [`pipenv`](https://docs.pipenv.org/) as alternative to the hoops I'm jumping through for pip + virtualenv
- 2017-12-08: configure completion to complete files if no other completion is applicable.
- 2017-11-09: `t` to emulate generating timestamps for natural-language dates

        cd $ZSH
        npm install locutus
        node -r $ZSH/node_modules/locutus -e \
            "console.log(require('locutus/php/datetime/strtotime')(Array.prototype.slice.call(process.argv, 1).join(' ')))" \
            now

    need some "vendor install" concept to do the `npm install` bits. Also remove relevant `.gitignore` entries.

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
- Break in https://direnv.net/ more

Solidify on usage of `if which cmd > /dev/null; then` versus `$+commands[cmd]`. See [here][p] for reference.
[p]: http://www.zsh.org/mla/users/2011/msg00070.html


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


