let g:VimPbcopyHost = "mac-laptop"
let g:VimPbcopyCmd = "pbcopy"

function! s:copyLines(startLine, endLine)
    let lines = shellescape(join(getline(a:startLine, a:endLine), "\\n"))
    execute "silent !echo " . lines . " | ssh " . g:VimPbcopyHost . " " . g:VimPbcopyCmd
    redraw! " Fix up the screen
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
