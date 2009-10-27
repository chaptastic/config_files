" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup
set nowritebackup
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
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

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

if has("folding")
  set foldenable
  set foldmethod=syntax
  set foldlevel=1
  set foldnestmax=2
  set foldtext=strpart(getline(v:foldstart),0,50).'\ ...\ '.substitute(getline(v:foldend),'^[\ #]*','','g').'\ '

  " automatically open folds at the starting cursor position
  autocmd BufReadPost .foldo!
endif

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab

" Always display the status line
set laststatus=2

" \ is the leader character
" let mapleader = "\\"
let mapleader = ","

" Edit the README_FOR_APP (makes :R commands work)
map <Leader>R :e doc/README_FOR_APP<CR>

" Leader shortcuts for Rails commands
" map <Leader>m :Rmodel 
" map <Leader>c :Rcontroller 
" map <Leader>v :Rview 
" map <Leader>u :Runittest 
" map <Leader>f :Rfunctionaltest 
" map <Leader>tm :RTmodel 
" map <Leader>tc :RTcontroller 
" map <Leader>tv :RTview 
" map <Leader>tu :RTunittest 
" map <Leader>tf :RTfunctionaltest 
" map <Leader>sm :RSmodel 
" map <Leader>sc :RScontroller 
" map <Leader>sv :RSview 
" map <Leader>su :RSunittest 
" map <Leader>sf :RSfunctionaltest 

" Hide search highlighting
map <Leader>h :set invhls <CR>

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Opens a tab edit command with the path of the currently edited file filled in
" Normal mode: <Leader>t
" map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" Maps autocomplete to tab
" imap <Tab> <C-N>

" Duplicate a selection
" Visual mode: D
vmap D y'>p

" For Haml
au! BufRead,BufNewFile *.haml         setfiletype haml

" No Help, please
map <F1> <Esc>

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

" Display extra whitespace
set list listchars=tab:»·,trail:·

" Edit routes
command! Rroutes :e config/routes.rb
command! RTroutes :tabe config/routes.rb

" Local config
if filereadable(".vimrc.local")
  source .vimrc.local
endif

" Use Ack instead of Grep when available
if executable("ack")
  set grepprg=ack\ -H\ --nogroup\ --nocolor
endif

" Color scheme
if has("gui_running")
  set guifont=Menlo:h12,Consolas:h12
  colorscheme zenburn
  " " set background=light
  " " colorscheme peaksea
  " " highlight LineNr guibg=#c0c0c0
  " " highlight NonText		guifg=#808080
  " " highlight SpecialKey guifg=#808080
  " set background=light
  " colorscheme peaksea
  " " colorscheme lucius

  " hi Normal guibg=#f0f0f0
  " hi LineNr guibg=#c0c0c0

  " " dark background
  " " highlight LineNr guibg=#101010
  " " highlight NonText		guifg=#808080
  " " highlight SpecialKey guifg=#808080
  " " highlight Cursor guibg=#60c060

  " " colorscheme wombat
  " " highlight LineNr guibg=#101010
  " " highlight NonText		guifg=#808080
  " " highlight SpecialKey guifg=#808080
else
  " set t_Co=256
  set background=light
  colorscheme peaksea
endif

" Typewriter mode (keep cursor centered) 
" set scrolloff=999

" Numbers
set number
set numberwidth=5

" Snippets are activated by Shift+Tab
let g:snippetsEmu_key = "<S-Tab>"

" Tab completion options
" (only complete to the longest unambiguous match, and show a menu)
set completeopt=longest,menu
set wildmode=list:longest,list:full

" case only matters with mixed case expressions
set ignorecase
set smartcase

" use hidden buffers instead of annoyingly closing
set hidden
set confirm

function! ToggleScratch()
  if expand('%') == g:ScratchBufferName
    quit
  else
    Sscratch
  endif
endfunction

map <leader>s :call ToggleScratch()<CR>

let NERDChristmasTree = 1
let NERDTreeShowBookmarks = 1
let NERDTreeChDirMode = 2
let NERDTreeWinSize = 30
let NERDTreeMoveMode = 2
let NERDTreeQuitOnOpen = 1

map <leader>t :NERDTreeToggle<CR>
nnoremap <silent> <Leader>bd :Bclose<CR>
nmap <leader>x :Bclose<CR>

" automatically save and restore views
au BufWinLeave * mkview
au BufWinEnter * silent! loadview

" keep four lines of context

let g:tcl_dfs_scrolloff = 4
let &scrolloff=g:tcl_dfs_scrolloff
let g:tcl_dfs_prevstate=&fullscreen
" let g:tcl_dfs_columns = &columns
function! DoFullScreen()
  if &fullscreen != g:tcl_dfs_prevstate
    echom "The value of fullscreen is" &fullscreen
    if &fullscreen
      " echo "Setting up for fullscreen"
      let g:tcl_dfs_scrolloff=&scrolloff
      let &scrolloff=999
    else
      " echo "Restoring pre-fullscreen state"
      let &scrolloff=g:tcl_dfs_scrolloff
    endif
    let g:tcl_dfs_prevstate=&fullscreen
  endif
endfunction
au VimResized * :call DoFullScreen()

let vimclojure#NailgunClient = "~/.vim/bin/ng"
" Clojure syntax support
let g:clj_highlight_builtins=1
let g:clj_paren_rainbow=1
au Bufenter,Bufnewfile *.clj setfiletype clojure
au Bufenter,Bufnewfile *.clj setl lisp
let g:clj_want_gorilla = 1
let g:clj_highlight_contrib = 1

" erlang settings
let g:erlangHighlightBif = 1

set spell
set spelllang=en_us

let g:rails_abbreviations = 0

set popt=syntax:y,duplex:long,paper:letter
