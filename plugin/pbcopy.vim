" Helper function to determine if Vim is running locally or if this is an
" SSH session.
function! s:isRunningLocally()
    if len($SSH_CLIENT)
        return 0
    else
        return 1
    endif
endfunction

function! s:getVimPbCopyProtocol()
    if exists("g:vim_pbcopy_protocol")
        return g:vim_pbcopy_protocol
    elseif isRunningLocally()
        return "local"
    else
        return "ssh"
    endif
endfunction

" let g:vim_pbcopy_ssh_host = "mac-laptop"
" let g:vim_pbcopy_ssh_port = 22
let g:vim_pbcopy_cmd = "pbcopy"

let g:vim_pbcopy_http_request = "curl -X POST -H 'Content-Type: text/plain' http://localhost:7700/pbcopy --data-urlencode @-"

vnoremap <silent> cy :<C-U>call <SID>copyVisualSelection(visualmode(), 1)<CR>
nnoremap <silent> cy :set opfunc=<SID>copyVisualSelection<CR>g@

function! s:getVisualSelection()
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][:col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    return lines
endfunction


function! s:getShellEscapedLines(listOfLines)
    " Join the lines with the literal characters '\n' (two chars) so that
    " they will be echo-ed correctly. Passing a non-zero second argument to
    " shellescape means it will escape "!" and other characters special to
    " Vim. See :help shellescape. We need this because otherwise execute"
    " will replace "!" with the previously-executed command and chaos will
    " ensue.

    " Note there is very behavior when attempting to copy a line which
    " contains the literal character \n. Example:
    "
    "   console.log('hello\nthere');

    if exists("g:vim_pbcopy_escape_backslashes") && g:vim_pbcopy_escape_backslashes
        " Global override is set and is truthy
        echom "[vim-pbcopy debug] forcing shellescape(escape(...))"
        return shellescape(escape(join(a:listOfLines, "\n"), '\'), 1)

    elseif exists("g:vim_pbcopy_escape_backslashes")
        " Global override is set and is falsey
        echom "[vim-pbcopy debug] forcing shellescape(...)"
        return shellescape(join(a:listOfLines, "\n"), 1)

    elseif s:isRunningLocally()
        " No global override set. We are running locally as determined by
        " the above helper function so we can make an educated guess that
        " escape() does NOT need to be invoked.

        " Confirmed working on Mac OS X Yosemite
        echom "[vim-pbcopy debug] shellescape(...)"
        return shellescape(join(a:listOfLines, "\n"), 1)

    else
        " No global override set. We are NOT running locally which
        " *probably* means the user is SSH-ed in to a Linux host. We can
        " make an educated guess that escape() DOES need to be called here.
        " So far works on all Linux distros I've used.
        echom "[vim-pbcopy debug] shellescape(escape(...))"
        return shellescape(escape(join(a:listOfLines, "\n"), '\'), 1)
    endif

endfunction

function! s:sendTextToPbCopy(escapedText)
    try
        echom "[vim-pbcopy debug] g:vim_pbcopy_protocol == \"" . s:getVimPbCopyProtocol() . "\""
        if s:getVimPbCopyProtocol() == "local"
            " If running locally we assume protocol == "local"
            " TODO: Don't do this. Allow users to use whatever protocol
            " whether running locally or not.

            " Call the UNIX echo command. The -n means do not output trailing newline.
            execute "silent !echo -n " . a:escapedText . " | " . g:vim_pbcopy_cmd

        elseif s:getVimPbCopyProtocol() == "ssh"
            " Call the UNIX echo command. The -n means do not output trailing newline.
            execute "silent !echo -n " . a:escapedText . " | ssh " . g:vim_pbcopy_host . " " . g:vim_pbcopy_cmd

        elseif s:getVimPbCopyProtocol() == "http"
            echom "[vim-pbcopy debug] No implementation yet for \"http\" protocol!"

        endif
        redraw! " Fix up the screen
        return 0
    catch /E121/
        " Undefined variable error
        echohl WarningMsg
        echom "[vim-pbcopy] If using the \"ssh\" protocol please set g:vim_pbcopy_host in your ~/.vimrc with something like: let g:vim_pbcopy_host = \"hostname.example.com\""
        echohl None
        return 1
    endtry
endfunction

function! s:copyVisualSelection(type, ...)
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@

    if a:0  " Invoked from Visual mode, use '< and '> marks.
      silent exe "normal! `<" . a:type . "`>y"
    elseif a:type == 'line'
      silent exe "normal! '[V']y"
    elseif a:type == 'block'
      silent exe "normal! `[\<C-V>`]y"
    else
      silent exe "normal! `[v`]y"
    endif

    let lines = split(@@, "\n")
    let escapedLines = s:getShellEscapedLines(lines)
    let error =  s:sendTextToPbCopy(escapedLines)

    " Reset the selection and register contents
    let &selection = sel_save
    " let @@ = reg_save
endfunction
