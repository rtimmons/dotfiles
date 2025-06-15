dotfiles
========

    My dotfiles >> your dotfiles

I jumped the shark (er..the boat) and switched to zsh. While poking around I found [holman's dotfiles](https://github.com/holman/dotfiles) and decided to blatantly copy a lot of his stuff.

Urgent TODOs  
------------

See [TODO.md](TODO.md) for a comprehensive list of all TODO items and improvements.

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


## Additional Notes

For a comprehensive list of TODO items and improvements, see [TODO.md](TODO.md).

### Useful Commands

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


