vim-pbcopy
==========
This is a Vim plugin that exposes a `:Copy` command which attempts to pipe
the results (via `ssh` if necessary) to the `pbcopy` command on a Mac OS X
client. What does this mean? It means you can visually select a block of
text in Vim, run `:Copy`, and have the text available in your Mac OS X
system clipboard.

Installation
------------
If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone https://github.com/ahw/vim-pbcopy.git
