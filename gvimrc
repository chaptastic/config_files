" Window size
set winwidth=131
let g:halfsize = 86
let g:fullsize = 171

" Font
set guifont=Consolas:h12.00

" No audible bell
set vb

" No toolbar
set guioptions-=T

" Setup project settings
let g:proj_window_width = 30
let g:proj_window_increment = 30
let g:proj_flags = "imst"

" Set the window size
set lines=50
let &columns = g:halfsize + g:proj_window_width + 1

" Use console dialogs
set guioptions+=c

" Start project plugin on new window
autocmd GUIEnter * Project
