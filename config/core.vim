"EDITOR
set number
set noshowmode
set showtabline=2
set switchbuf=uselast
"set switchbuf=usetab,newtab
set splitright
set splitbelow
set noequalalways
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set showbreak=↪\ 
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set list

set smartindent
"set nowrap
set smartcase
set noswapfile
if has("persistent_undo")
    set undodir=$HOME/.vim/undodir
endif
set undofile
set incsearch
set path+=**
set wildmenu
set mouse=nvi
set backspace=indent,eol,start
set clipboard^=unnamed,unnamedplus

set makeprg=/usr/bin/env\ bash\ -ic

"set foldmethod=indent
"set foldlevel=1
"set foldclose=all

" Added with CoC plugin
" set fail if hidden is not set.
"set hidden

" Some servers have issues with backup files, see #649.
"set nobackup
"set nowritebackup
"
" Give more space for displaying messages.
"set cmdheight=1
"
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
"set updatetime=300
"
" Don't pass messages to |ins-completion-menu|.
"set shortmess+=c

" Recently vim can merge signcolumn and number column into one
"set signcolumn=number

"set breakindent
"set breakindentopt=sbr
"set cpoptions+=n

" Always delete to black hole register
nnoremap d "_d
vnoremap d "_d

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"KEY MAPPINGS

"this preventes escaping embedded editors
"tnoremap <Esc> <C-\><C-n>
tmap <silent> <C-w> <C-\><C-n>


map <F12> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

"editor mappings
noremap <CR> i<CR><ESC>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"ENCODING

scriptencoding utf-8
set encoding=utf-8

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"THEME

syntax enable
"set t_Co=256
set background=dark
"colorscheme PaperColor
colorscheme gruvbox8

let g:gruvbox_plugin_hi_groups = 1
let g:gruvbox_transp_bg = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"NERD COMMENTER

filetype plugin on


set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
