" let g:vim_pbcopy_host = "mac-laptop"
let g:vim_pbcopy_cmd = "pbcopy"

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
    return shellescape(join(a:listOfLines, '\n'), 1)
endfunction

function! s:sendTextToPbCopy(text)
    try
        if len($SSH_CLIENT)
            " Call the UNIX echo command. The -n means do not output trailing newline.
            execute "silent !echo -n " . a:text . " | ssh " . g:vim_pbcopy_host . " " . g:vim_pbcopy_cmd
        else
            " Call the UNIX echo command. The -n means do not output trailing newline.
            execute "silent !echo -n " . a:text . " | " . g:vim_pbcopy_cmd
        endif
        redraw! " Fix up the screen
        return 0
    catch /E121/
        " Undefined variable error
        echohl WarningMsg
        echom "Please set g:vim_pbcopy_host in your ~/.vimrc with something like: 'let g:vim_pbcopy_host = \"hostname.example.com\"'"
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
    let @@ = reg_save
endfunction
