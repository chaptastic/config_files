set nocompatible
let mapleader = ","

call pathogen#runtime_append_all_bundles() 

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set hidden
set nobackup
set nowritebackup
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set cursorline

" No audible bell
set vb

" No toolbar, no scollbars, use menus, use tabs, console dialogs
set guioptions=egmrtc

" Don't use Ex mode, use Q for formatting
map Q gq

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
  set hlsearch
endif

if has("gui_macvim")
  set fuoptions=maxvert,maxhorz
endif

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype off
filetype plugin indent on

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
	au!

	" For all text files set 'textwidth' to 78 characters.
	autocmd FileType text setlocal textwidth=78

	" When editing a file, always jump to the last known cursor position.
	" Don't do it when the position is invalid or when inside an event handler
	" (happens when dropping a file on gvim).
	autocmd BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\   exe "normal g`\"" |
		\ endif

augroup END

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab
set smarttab

" Display extra whitespace
" set list listchars=tab:»·,trail:·,eol:$
set list listchars=tab:▸·,trail:·,eol:¬

" Always display the status line
set laststatus=2
set cmdheight=2
set shortmess=atT

set statusline=%<%f\ %{fugitive#statusline()}\ %h%m%r%=%-14.(%l,%c%V%)\ %P


" No Help, please
map <F1> <Esc>
imap <F1> <Esc>

" Press ^F from insert mode to insert the current file name
imap <C-F> <C-R>=expand("%")<CR>

" Apple-Enter opens a new line below in edit mode
imap <D-Enter> <C-o>o

" Map emacs input keys
imap <C-a> <C-o>^
imap <C-e> <C-o>$
imap <C-k> <C-o>D
cmap <C-a> <C-Left>
cmap <C-e> <C-Right>

" Map Cmd-/ to comment block in visual and normal mode
vmap <D-/> :TComment<CR>
nmap <D-/> :TComment<CR>

if has("gui_running")
  set guifont=Menlo:h10,Mensch:h10,Consolas:h10
endif

set number
set numberwidth=5

set ignorecase
set smartcase

set vop=cursor,folds,unix
au BufWinLeave * silent! mkview
au BufWinLeave * silent! loadview

set popt=syntax:y,duplex:long,paper:letter

nmap <leader>X :Bclose!<CR>
nmap <leader>x :Bclose<CR>

" nmap <leader>f :LustyFilesystemExplorerFromHere<CR>
" nmap <leader>b :LustyBufferExplorer<CR>

nmap <leader>f :FufFileWithCurrentBufferDir<CR>
nmap <leader>b :FufBuffer<CR>

set spell
set spelllang=en_us

set formatprg=par\ -re

nnoremap <F5> :GundoToggle<CR>

" colorscheme zenburn
" colorscheme pyte
" 
if has('gui_running')
    set background=light
else
    set background=dark
endif

colorscheme solarized

function! ToggleBackground()
  if (background=="dark")
    set background="light"
    colorscheme solarized
  else
    set background="dark"
    colorscheme solarized
  endif
endfunction
command! Togbg call ToggleBackground()
nnoremap <F5> :call ToggleBackground()<CR>
inoremap <F5> <ESC>:call ToggleBackground()<CR>a
vnoremap <F5> <ESC>:call ToggleBackground()<CR>

" let vimclojure#NailgunClient = "/Users/chap/bin/ng"
" let vimclojure#WantNailgun = 1

let vimclojure#HighlightBuiltins=1      " Highlight Clojure's builtins
let vimclojure#ParenRainbow=1           " Rainbow parentheses'!
let vimclojure#FuzzyIndent = 1

let g:slimv_impl = 'clojure'
let g:slimv_port = 4005
let g:slimv_keybindings = 2
let g:slimv_lisp = '"java -cp ~/.m2/repository/org/clojure/clojure/1.3.0-beta1/clojure-1.3.0-beta1.jar clojure.main"'


" Configure browser for haskell_doc.vim
let g:haddock_browser = "open"
let g:haddock_browser_callformat = "%s %s"
let g:haddock_docdir = "/usr/share/doc/ghc/html/"
let g:haddock_indexfiledir="~/.vim/haddock/"

map <unique> <silent> <Leader>z <Plug>SimpleFold_Foldsearch

" Show syntax highlighting groups for word under cursor
nmap <leader>z :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

map <leader>t <Plug>PeepOpen


augroup vagrant
  au!
  au BufRead,BufNewFile Vagrantfile set filetype=ruby
augroup END
