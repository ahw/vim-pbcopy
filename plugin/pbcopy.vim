" let g:VimPbcopyHost = "mac-laptop"
let g:VimPbcopyCmd = "pbcopy"

vnoremap <silent> cy :<C-U>call <SID>copyVisualSelection()<CR>

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
            execute "silent !echo -n " . a:text . " | ssh " . g:VimPbcopyHost . " " . g:VimPbcopyCmd
        else
            " Call the UNIX echo command. The -n means do not output trailing newline.
            execute "silent !echo -n " . a:text . " | " . g:VimPbcopyCmd
        endif
        redraw! " Fix up the screen
        return 0
    catch /E121/
        " Undefined variable error
        echohl WarningMsg
        echom "Please set g:VimPbcopyHost in your ~/.vimrc with something like: 'let g:VimPbcopyHost = \"hostname.example.com\"'"
        echohl None
        return 1
    endtry
endfunction

function! s:copyVisualSelection()
    let lines = s:getVisualSelection()
    let escapedLines = s:getShellEscapedLines(lines)
    let error =  s:sendTextToPbCopy(escapedLines)
    if !error
        " Note: gv selects the previous visual selection again
        execute "normal! gvy"
    endif
endfunction
