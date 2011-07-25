"=============================================================================
"    Copyright: Copyright (C) 2010 Niels Aan de Brugh
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               filtering.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damages
"               resulting from the use of this software.
" Name Of File: smartparens.vim
"  Description: Smart Behavior of Parentheses (ParEdit ultra-light)
"   Maintainer: Niels Aan de Brugh (nielsadb+vim at gmail dot com)
" Last Changed: 25 Aug 2010
"      Version: See g:smartparens_version for version number.
"        Usage: This file should reside in the plugin directory and be
"               automatically sourced.
"=============================================================================

if exists("g:smartparens_version")
    finish
endif
let g:smartparens_version = "0.2"

if !exists("g:smartparens_exclude")
    let g:smartparens_exclude = ">"
endif

if !exists("g:smartparens_escape")
    let g:smartparens_escape = "`"
endif

function! s:NextCharIs(ch)
    let l:origPos = getpos(".")
    let l:origSearch = @/
    call search("\\S", "cW")
    if match(getline("."), "^" . a:ch, col(".")-1) != -1
        let l:pos = getpos(".")
    else
        let l:pos = []
    end
    let @/ = l:origSearch
    call setpos(".", l:origPos)
    return l:pos
endfunction

function! s:ZapToIfNextCharIs(ch)
    let l:pos = s:NextCharIs(a:ch)
    let l:origPos = getpos(".")
    if len(l:pos) && l:pos != l:origPos
        while l:pos[1] - l:origPos[1]
            normal! J
            let l:pos[1] = l:pos[1] - 1
        endwhile
        call setpos(".", l:origPos)
        exe "normal \"_dt" . a:ch
    end
    return len(l:pos)
endfunction

function! s:MatchOf(pos)
    call setpos(".", a:pos)
    silent! normal! %
    return getpos(".")
endfunction

function! s:DeleteBracket(pos, open)
    call setpos(".", a:pos)
    if match(getline("."), "^" . a:open, col(".")-1) != -1
        normal! rA
    else
        normal! rB
    end
endfunction

function! s:UnDeleteBracket(pos, open, close)
    call setpos(".", a:pos)
    if match(getline("."), "A", col(".")-1) != -1
        exe "normal! r" . a:open
    else
        exe "normal! r" . a:close
    end
endfunction

function! s:GoodForBalance(startpos, open, close)
    " This function assumes the caller just put an opening bracket on
    " a:startpos.  This function returns 1 if adding this bracket is
    " good for the balance of brackets, and false otherwise.
    let l:deletions = []
    let l:cur = a:startpos
    let l:cbm = s:MatchOf(l:cur)
    while l:cur != l:cbm
        call s:DeleteBracket(l:cur, a:open)
        call add(l:deletions, l:cur)
        let l:cur = l:cbm
        let l:cbm = s:MatchOf(l:cur)
    endwhile 
    for d in l:deletions
        call s:UnDeleteBracket(d, a:open, a:close)
    endfor
    call setpos(".", a:startpos)
    return len(l:deletions) % 2
endfunction

function! OpenBracket(open, close)
    exe "silent! normal! i" . a:open
    if s:GoodForBalance(getpos("."), a:open, a:close)
        normal! l
    else
        exe "normal! a" . a:close
    end
endfunction

function! CloseBracket(closer)
    if !s:ZapToIfNextCharIs(a:closer)
        exe "normal! i" . a:closer
    end
    normal! l
endfunction

function! OpenCurlyBracket()
    if match(getline("."), "^{\\w*}", col(".")-2) != -1
        normal i
        normal k$
    else
        call OpenBracket("{", "}")
    end
endfunction

function! CloseCurlyBracket()
    let l:pos = s:NextCharIs("}")
    if len(l:pos)
        let l:cur = getpos(".")
        while (l:pos[1] - l:cur[1]) > 1
            normal! J
            let l:pos[1] = l:pos[1] - 1
        endwhile
        call setpos(".", l:pos)
        normal! l
    else
        normal! i}
    end
endfunction

function! PutBrackets(open, close)
    let l:count = v:count
    if l:count
        let l:origPos = getpos(".")
        exe "normal! i" . a:open
        while l:count > 1
            normal! W
            let l:count = l:count - 1
        endwhile
        exe "normal! ea" . a:close
        call setpos(".", l:origPos)
    else
        exe "normal! " . a:open
    end
endfunction

function! s:DefineEscapedMapping(brackets)
    for bracket in a:brackets
        exe "inoremap <buffer> ".g:smartparens_escape.bracket." ".bracket
    endfor
endfunction

function! RemapParensForBuffer()
    if stridx(g:smartparens_exclude, "(") == -1 && stridx(&matchpairs, "(:)") != -1
        call s:DefineEscapedMapping(["(", ")"])
        inoremap <buffer> ) <C-o>:call CloseBracket(")")<CR>
        inoremap <buffer> ( <C-o>:call OpenBracket("(", ")")<CR>
        inoremap <buffer> ) <C-o>:call CloseBracket(")")<CR>
        nnoremap <buffer> ( :<C-u>call PutBrackets("(", ")")<CR>
    endif

    if stridx(g:smartparens_exclude, "[") == -1 && stridx(&matchpairs, "[:]") != -1
        call s:DefineEscapedMapping(["[", "]"])
        inoremap <buffer> [ <C-o>:call OpenBracket("[", "]")<CR>
        inoremap <buffer> ] <C-o>:call CloseBracket("]")<CR>
        nnoremap <buffer> [ :<C-u>call PutBrackets("[", "]")<CR>
    endif

    if stridx(g:smartparens_exclude, "<") == -1 && stridx(&matchpairs, "<:>") != -1
        call s:DefineEscapedMapping(["<", ">"])
        inoremap <buffer> < <C-o>:call OpenBracket("<", ">")<CR>
        inoremap <buffer> > <C-o>:call CloseBracket(">")<CR>
        nnoremap <buffer> < :<C-u>call PutBrackets("<", ">")<CR>
    endif

    if stridx(g:smartparens_exclude, "{") == -1 && stridx(&matchpairs, "{:}") != -1
        call s:DefineEscapedMapping(["{", "}"])
        inoremap <buffer> { <C-o>:call OpenCurlyBracket()<CR>
        inoremap <buffer> } <C-o>:call CloseCurlyBracket()<CR>
        nnoremap <buffer> { :<C-u>call PutBrackets("{", "}")<CR>
    endif
endfunction


