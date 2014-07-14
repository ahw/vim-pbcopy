vim-pbcopy
==========
This is a Vim plugin that exposes a `cy` mapping in Visual mode and a
`cy{motion}` mapping in Normal mode which both attempt to yank the
selected/moved-over text and pipe it (via `ssh` if necessary) to the
`pbcopy` command on a Mac OS X client. What does this mean? It means you can
use `cy` wherever you'd normally use `y` and have that text available in
your Mac OS X system clipboard, whether you're working locally or remotely.
It also performs a simple `y` yank operation on your selection so you'll
have it in the default `"` yank register as well.

Installation
------------
If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone https://github.com/ahw/vim-pbcopy.git


Local Usage
-----------
Use `cy{motion}` to copy text to the Mac OSX system clipboard or hit `cy`
after selecting text in Visual mode. In the background it is simply running
running 

```sh
echo -n "whatever text you copied" | pbcopy
```

Remote Usage
------------
Nothing changes except you need to set the Vim global variable
`g:vim_pbcopy_host` variable in your `~/.vimrc` file.

> **~/.vimrc**
>
> ```vim
> let g:vim_pbcopy_host = "your-mac-laptop.example.com"
> ```

In the background it pipes the copied text to your Mac client's `pbcopy`
over SSH.

```sh
echo -n "whatever text you copied" | ssh your-mac-laptop.example.com pbcopy
```

This assumes that you have an SSH server running on your laptop, of course.
Note: I haven't tested this using password-based SSH logins (my
configuration uses SSH keys).
