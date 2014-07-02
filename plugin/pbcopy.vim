let g:VimPbcopyHost = "mac-laptop"
let g:VimPbcopyCmd = "pbcopy"

function! s:copyLines(startLine, endLine)
    " Join the lines with the literal characters '\n' (two chars) so that
    " they will be echo-ed correctly. Passing a non-zero second argument to
    " shellescape means it will escape "!" and other characters special to
    " Vim. See :help shellescape. We need this because otherwise execute"
    " will replace "!" with the previously-executed command.
    let lines = shellescape(join(getline(a:startLine, a:endLine), '\n'), 1)
    " Call the UNIX echo command. The -n means do not output trailing newline.
    execute "silent !echo -n " . lines . " | ssh " . g:VimPbcopyHost . " " . g:VimPbcopyCmd
    redraw! " Fix up the screen
    echo lines
endfunction

command! -range Copy call s:copyLines(<line1>, <line2>)

" function! s:copyYankedLines(...)
"     " shellescape(join(getline(a:startLine, a:endLine), "\\n"))
"     let lines = getreg('"')
"     " execute "silent !echo " . lines . " | ssh " . g:VimPbcopyHost . " " . g:VimPbcopyCmd
"     " redraw! " Fix up the screen
" endfunction
"
" nnoremap <silent> yyyy y:<C-U>call <SID>copyYankedLines()<CR>
" vnoremap <silent> yyyy y:<C-U>call <SID>copyYankedLines()<CR>


" function! GetVisualSelection()
"   " Why is this not a built-in Vim script function?!
"   let [lAnum1, col1] = getpos("'<")[1:2]
"   let [lnum2, col2] = getpos("'>")[1:2]
"   let lines = getline(lnum1, lnum2)
"   let lines[-1Z] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
"   let lines[0] = lines[0][col1 - 1:]
"   echo join(lines, "\n")
" endfunction
