if has("gui_running")

  set equalalways

  function! IsWinSplit()
    for item in tabpagebuflist()
      let l:bufwidth = winwidth(bufwinnr(item))
      if &columns != l:bufwidth && g:halfsize != l:bufwidth && item != g:proj_running
        return 1
      endif
    endfor
    return 0
  endfunction

  function! SetWidthForSplit()
    if IsWinSplit()
      let l:newcols = g:fullsize
    else
      let l:newcols = g:halfsize
    endif
    if g:proj_running
      let l:newcols += g:proj_window_width + 1
    endif
    let &columns = l:newcols
  endfunction

  augroup splitsize
    autocmd!
    autocmd WinEnter * call SetWidthForSplit()
  augroup END

endif
