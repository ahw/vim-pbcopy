vim-pbcopy
==========
This is a Vim plugin that exposes a `cy` mapping in VISUAL mode which
attempts to pipe the visual selection (via `ssh` if necessary) to the
`pbcopy` command on a Mac OS X client. What does this mean? It means you can
visually select a block of text in Vim, hit `cy`, and have the text
available in your Mac OS X system clipboard. It also performs a simple `y`
yank operation on the same visual selection so you'll have it in the default
`"` yank register as well.

Installation
------------
If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone https://github.com/ahw/vim-pbcopy.git

**You must also set the g:VimPbcopyHost variable in your `~/.vimrc` file.**

> **~/.vimrc**
>
> ```vim
> let g:VimPbcopyHost = "your-mac-laptop.example.com"
> ```

Local Usage
-----------
> TODO

Remote Usage
------------
> TODO
