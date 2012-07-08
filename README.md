dotfiles
========

    My dotfiles >> your dotfiles

I jumped the shark (er..the boat) and switched to zsh. While poking around I found [holman's dotfiles](https://github.com/holman/dotfiles) and decided to blatantly copy a lot of his stuff.

I'm slowly moving things over from my old subversion dotfiles repository as I realize that I'm missing them. Scorched earth is delicious.

.0zh?
-----

tl;dr:

> Everything ending in .0zsh is sourced before everything ending in .zsh

Everything in this repo that ends in .zsh is sourced upon startup. (Check out zsh/zshrc.symlink.). Problem is there are bootstrap issues. Some things depend on other things. Apparently I can't pass a custom comparator into zsh's globbing, so it's impossible to, say, run everything in asciibetical order based on `basename` of the file. If it were, you could just name your files `000-prompt.zsh` or whatever.


TODO
----

- should put my textmate bundle here
- export NODE_PATH="/usr/local/lib/node_modules:$NODE_PATH"
- export LESSEDIT='mate -l %lm %f'
- export SPROJ_BASE="http://svn.ganon.com/archive"

Credits
-------

I've stolen almost everything here.  I usually put the original source URL in comments next to the stolen bits.  Please contact me if I've stolen something and you want it back.


