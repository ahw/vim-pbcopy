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

You can configure the local pbcopy command in your `~/.vimrc` file:

> **~/.vimrc**
>
> ```vim
> let g:vim_pbcopy_local_cmd = "pbcopy"
> ```


Remote Usage
------------
### Option 1: Port Forwarding + Clipper

> Clipper is an OS X 'launch agent' that runs in the background providing a
> service that exposes the local clipboard to tmux sessions and other
> processes running both locally and remotely. ... We can use it from any
> process, including Vim
>
> Source: https://github.com/wincent/clipper/blob/master/README.md

Clipper listens for tcp data on a select localhost port, and puts all
input it receipes on the system clipboard. This is useful for both local and
remote use. Locally, using clipper rather than `pbcopy` circumvents known
problems with `pbcopy` and `tmux`. Remotely, you can forward a remote port
to the local clipper's port via an ssh reverse tunnel.

Clipper can be configured in a variety of ways. Here's what's worked for me.

1. `brew install clipper` (install Clipper)
2. `brew services start clipper` (start the Clipper daemon)
3. `ssh -R 8377:localhost:8377 my.remote.host` (set up SSH remote port forwarding)
4. Add the following to `~/.vimrc` on the **remote host**: `let g:vim_pbcopy_remote_cmd = "nc localhost 8377"`. If for some reason things still aren't working, you can debug Clipper in isolation by running `echo "hello from local machine" | nc localhost 8377` on your local machine, and you can debug the port forwarding setup by  running `echo "hello from remote machine" | nc localhost 8377` from the remote machine.

### Option 2: Direct SSH Access to Local Host
Nothing changes except you need to set the Vim global variable
`g:vim_pbcopy_remote_cmd` variable in your `~/.vimrc` file to your preferred
way of running pbcopy on your local machine.

> **~/.vimrc**
>
> ```vim
> let g:vim_pbcopy_remote_cmd = "ssh your-mac-laptop.example.com pbcopy"
> ```

This will pipe the copied text to your Mac client's `pbcopy` over SSH.

```sh
echo -n "whatever text you copied" | ssh your-mac-laptop.example.com pbcopy
```

This assumes that you have an SSH server running on your laptop, of course.
Note: I haven't tested this using password-based SSH logins (my
configuration uses SSH keys).

See **Option #1** above for other remote usage possiblities.

Troubleshooting
---------------

### Problems with Newlines
There are some inconsistencies around the way backslashes are escaped on
different systems. Try copying some text with `\` and `\n` characters. If
you're getting incorrect output when you then try to paste that text somewhere,
see the table below for how to remedy.


If you copied this          | and pasted this               | add this to ~/.vimrc
---                         | ---                           | ---
console.log('some\nthing'); | console.log('some\nthing');   | Nothing! It Just Works&trade;
console.log('some\nthing'); | console.log('some<br>thing'); | `let g:vim_pbcopy_escape_backslashes = 1`
console.log('some\nthing'); | console.log('some\\\nthing'); | `let g:vim_pbcopy_escape_backslashes = 0`
