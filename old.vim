"EDITOR
set number
set noshowmode
set showtabline=2
set switchbuf=usetab,newtab
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
set clipboard=unnamed
set clipboard=unnamedplus
set makeprg=/usr/bin/env\ bash\ -ic

"set foldmethod=indent
"set foldlevel=1
"set foldclose=all

" set fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
"
" Give more space for displaying messages.
set cmdheight=1
"
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300
"
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Recently vim can merge signcolumn and number column into one
if !has('nvim')
    set signcolumn=number
endif

"set breakindent
"set breakindentopt=sbr
"set cpoptions+=n

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"KEY MAPPINGS

if has('nvim')
    "tnoremap <Esc> <C-\><C-n>
    tmap <silent> <C-w> <C-\><C-n>
endif

"panes

function! IsBufVisible(buf)
    return a:buf != -1 && bufwinnr(a:buf) != -1
endfunction

function! HideBuf(buf)
    if IsBufVisible(a:buf)
        exe bufwinnr(a:buf) . 'hide'
        return 1
    endif
    return 0
endfunction

function! GetBufNrByName(name)
    for buf in range(1, bufnr('$'))
        if bufname(buf) =~ a:name
            return bufnr(buf)
        endif
    endfor
    return -1
endfunction

"left pane

let g:leftPaneWidth = 31

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"NERD TREE
let NERDTreeShowHidden = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"TAGBAR
let g:tagbar_left = 1
let g:tagbar_width = g:leftPaneWidth
let g:tagbar_compact = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"UNDOTREE
let g:undotree_SplitWidth = g:leftPaneWidth
let g:undotree_HelpLine = 0
let g:undotree_SetFocusWhenToggle = 1

function! LeftPaneHideOther(opt)
    if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1 && a:opt !=# "nerdtree"
        NERDTreeToggle
    elseif exists("t:tagbar_buf_name") && bufwinnr(t:tagbar_buf_name) != -1 && a:opt !=# "tagbar"
        TagbarToggle
    elseif exists("t:undotree") && t:undotree.IsVisible() && a:opt !=# "undotree"
        UndotreeToggle
    endif
endfunction

function! LeftPaneNERDTree()
    call LeftPaneHideOther("nerdtree")
    if exists("t:NERDTreeBufName")
        NERDTreeToggle
    else
        silent NERDTreeMirror
        NERDTreeFocus
    endif
    call lightline#update()
endfunction

function! LeftPaneTagbar()
    call LeftPaneHideOther("tagbar")
    if exists("t:tagbar_buf_name") && bufwinnr(t:tagbar_buf_name) != -1
        TagbarToggle
    else
        TagbarOpen fj
    endif
    call lightline#update()
endfunction

function! LeftPaneUndotree()
    call LeftPaneHideOther("undotree")
    if exists("t:undotree")
        UndotreeToggle
    else
        UndotreeShow
    endif
endfunction

nmap <silent> <F2> :call LeftPaneNERDTree()<CR>
tmap <silent> <F2> <C-w>:call LeftPaneNERDTree()<CR>
nmap <silent> <F3> :call LeftPaneTagbar()<CR>
tmap <silent> <F3> <C-w>:call LeftPaneTagbar()<CR>
nmap <silent> <F4> :call LeftPaneUndotree()<CR>
tmap <silent> <F4> <C-w>:call LeftPaneUndotree()<CR>

autocmd tableave * call LeftPaneHideOther("")

"bottom pane

let g:bottomPaneHeight = 12

function! BottomPaneHideOther(opt)
    for buf in range(1, bufnr('$'))
        if bufname(buf) == '[BufExplorer]' && bufwinnr(buf) != -1 && a:opt !=# "bufexplorer"
            call HideBuf(buf)
        elseif getbufvar(buf, 'current_syntax') == 'qf' && a:opt !=# "quickfix"
            call HideBuf(buf)
        elseif ((!has('nvim') && bufname(buf) == '!/bin/bash') || (has('nvim') && bufname(buf) =~ '^term://.*/usr/bin/env bash')) && a:opt !=# "terminal"
            call HideBuf(buf)
        endif
    endfor
endfunction

"buflist pane
let g:bufExplorerSplitHorzSize = g:bottomPaneHeight
let g:bufExplorerDisableDefaultKeyMapping = 1
let g:bufExplorerDefaultHelp = 0

function! BufExplorerReload()
    unlet g:bufexplorer_version
    call plug#begin('~/.vim/plugged')
    Plug 'jlanzarotta/bufexplorer'
    call plug#end()
endfunction

function! BufExplorerToggle()
    let bufnr = GetBufNrByName('\[BufExplorer\]')
    if IsBufVisible(bufnr)
        ToggleBufExplorer
    else
        call BottomPaneHideOther("bufexplorer")
        wincmd b
        BufExplorerHorizontalSplit
        let bufnr = GetBufNrByName('\[BufExplorer\]')
        if !IsBufVisible(bufnr)
            call BufExplorerReload()
            BufExplorerHorizontalSplit
        endif
        wincmd J
    endif
endfunction

nmap <silent> <F7> :call BufExplorerToggle()<CR>
tmap <silent> <F7> <C-w>:call BufExplorerToggle()<CR>

"quickfix pane

function! IsBufQuickFix(bufnr)
    return getbufvar(a:bufnr, 'current_syntax') == 'qf'
endfunction

function! GetQuickFixBufNr()
    for buf in range(1, bufnr('$'))
        if IsBufQuickFix(buf) 
            return buf
        endif
    endfor
    return -1 
endfunction

function! QuickFixToggle()
    let bufnr = GetQuickFixBufNr()
    if IsBufVisible(bufnr)
        cclose
    else
        call BottomPaneHideOther("quickfix")
        silent exe 'copen ' . g:bottomPaneHeight
        set ma
        wincmd J
    endif
endfunction

autocmd bufcreate * if IsBufQuickFix(bufnr()) | silent exe 'map <silent> <buffer> <CR> :.cc<CR>' | endif

function! MyMake(task)
    call BottomPaneHideOther("quickfix")
    silent exe 'Make! ' . a:task
    Copen!
    silent exe bufwinnr(GetQuickFixBufNr()) . 'resize ' . g:bottomPaneHeight
endfunction

command! -nargs=* MyMake call MyMake("<args>")

nmap <F10> :MyMake<SPACE>
tmap <F10> <C-w>:MyMake<SPACE>

nmap <silent> <F6> :call QuickFixToggle()<CR>
tmap <silent> <F6> <C-w>:call QuickFixToggle()<CR>

"terminal pane

function! IsBufTerminal(bufnr)
    if !has('nvim')
        for nr in term_list()
            if nr == a:bufnr
                return 1
            endif
        endfor
    else
        return '' != getbufvar(a:bufnr, 'term_title')
    endif
    return 0
endfunction

function! TerminalToggle()
    if !has('nvim')
        let term_bufnr = GetBufNrByName('!/bin/bash')
    else
        let term_bufnr = GetBufNrByName('^term://.*/usr/bin/env bash')
    endif
    if !HideBuf(term_bufnr)
        call BottomPaneHideOther("terminal")
        wincmd b
        if term_bufnr != -1
            silent exe g:bottomPaneHeight . 'split #' . term_bufnr
            startinsert
        else
            if !has('nvim')
                terminal
                silent exe 'resize ' . g:bottomPaneHeight
            else
                silent exe g:bottomPaneHeight . 'split term:///usr/bin/env bash'
                setlocal nonumber
                startinsert
            endif
        endif
        set nonumber
        wincmd J
    endif
endfunction

nmap <silent> <F5> :call TerminalToggle()<CR>
tmap <silent> <F5> <C-w>:call TerminalToggle()<CR>

autocmd tableave * call BottomPaneHideOther("") 

"terminal tab

function! OpenTerminal()
    $tabnew
    if !has('nvim')
        call term_start(&shell, {'term_name': 'shell', 'term_finish': 'close', 'curwin': 1, 'norestore': 1})
    else
        terminal
        setlocal nonumber
        startinsert
    endif
endfunction

if !has('nvim')
    nmap <silent> <S-F5> :call OpenTerminal()<CR>
    tmap <silent> <S-F5> <C-w>:call OpenTerminal()<CR>
else
    nmap <silent> <F17> :call OpenTerminal()<CR>
    tmap <silent> <F17> <C-w>:call OpenTerminal()<CR>
endif
"midnight commander

function! OpenMC()
    if !has('nvim')
        let name = "Midnight Commander"
    else
        let name = "^term://.*:mc --skin=gotar"
    endif
    let bufnr = GetBufNrByName(name)
    
    if bufnr != -1
        for i in range(tabpagenr("$"))
            if index(tabpagebuflist(i + 1), bufnr) != -1
                silent exe "tabnext " . (i + 1)
                setlocal nonumber
                return
            endif
        endfor
        silent exe "$tabnew | buffer " . bufnr
        setlocal nonumber
        return
    endif

    $tabnew
    if !has('nvim')
        call term_start('mc --skin=gotar', {'term_name': name, 'term_finish': 'close', 'curwin': 1, 'norestore': 1})
    else
        call termopen('mc --skin=gotar')
        setlocal nonumber
        startinsert
    endif
endfunction

nmap <silent> <F8> :call OpenMC()<CR>
tmap <silent> <F8> <C-w>:call OpenMC()<CR>
"terminal escape

"tnoremap <C-C> <C-w>

"tab navigation
tmap <silent> <C-Left> <C-w>:tabprev<CR>
tmap <silent> <C-h> <C-w>:tabprev<CR>
tmap <silent> <C-Right> <C-w>:tabnext<CR>
tmap <silent> <C-l> <C-w>:tabnext<CR>
map <C-Left> <C-PageUp>
map <C-h> <C-PageUp>
map <C-Right> <C-PageDown>
map <C-l> <C-PageDown>
tnoremap <silent> <A-Left> <C-w>N:-tabmove<CR>
tnoremap <silent> <A-h> <C-w>N:-tabmove<CR>
tnoremap <silent> <A-Right> <C-w>N:+tabmove<CR>
tnoremap <silent> <A-l> <C-w>N:+tabmove<CR>
nnoremap <silent> <A-Left> :-tabmove<CR>
nnoremap <silent> <A-h> :-tabmove<CR>
nnoremap <silent> <A-Right> :+tabmove<CR>
nnoremap <silent> <A-l> :+tabmove<CR>

"window navigation
tmap <C-Up> <C-w>W
tmap <C-k> <C-w>W
tmap <C-Down> <C-w>w
tmap <C-j> <C-w>w
map <C-Up> <C-w>W
map <C-k> <C-w>W
map <C-Down> <C-w>w
map <C-j> <C-w>w

"terminal scrolls
"tmap <ScrollWheelUp> <C-w>N

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
set t_Co=256
"set background=dark
"colorscheme PaperColor
colorscheme gruvbox8

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"NERD COMMENTER

filetype plugin on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"LIGHTLINE
let g:lightline = {
\ 'active': {
\   'left': [ [ 'mode', 'paste' ],
\             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
\  'right': [ [ 'percent' , 'align' ],
\             [ 'lineinfo' ],
\             [ 'fileformat', 'fileencoding', 'filetype' ] ]
\ },
\ 'inactive' : {
\      'left': [ [ 'gitbranch', 'filename' ] ],
\     'right': [ [ 'percent' ],
\                [ 'lineinfo' ] ]
\ },
\ 'tabline' : {
\     'left': [ [ 'tabs' ] ],
\    'right': [ [ 'close' ],
\               [ 'cocstatus' ] ]
\ },
\ 'tab': {
\   'active': ['tabnum', 'filename', 'readonly', 'modified'],
\   'inactive': ['tabnum', 'filename', 'readonly', 'modified']
\ },
\ 'component' : {
\    'align': '%<',
\ },
\ 'component_function': {
\   'gitbranch': 'Lightline_gitbranch',
\   'readonly': 'Lightline_readonly',
\   'mode': 'Lightline_mode',
\   'modified': 'Lightline_modified',
\   'filename': 'Lightline_filename',
\   'cocstatus': 'coc#status',
\   'fileformat': 'Lightline_fileformat',
\   'filetype': 'Lightline_filetype',
\   'lineinfo': 'Lightline_lineinfo',
\   'percent': 'Lightline_percent',
\   'fileencoding': 'Lightline_encoding'
\ },
\ 'tab_component_function': {
\   'filename': 'Lightline_tab_filename', 'modified': 'Lightline_tab_modified',
\   'readonly': 'Lightline_tab_readonly', 'tabnum': 'lightline#tab#tabnum'
\ },
"\ 'separator': { 'left': "\ue0b8", 'right': "\ue0ba" },
"\ 'subseparator': { 'left': "\ue0b9", 'right': "\ue0bb" }
\ }
let g:lightline_fields = {
\ 'nerdtree' : {
\   'gitbranch': 1,
\   'mode': 'EXPLORE',
\  },
\ 'tagbar' : {
\   'mode': 'TAGS',
\  },
\ 'undotree' : {
\   'mode': 'UNDO',
\  },
\ 'qf' : {
\   'mode': 'QUICKFIX',
\  },
\ 'bufexplorer' : {
\   'mode': 'BUFFERS',
\  },
\ 'help' : {
\   'mode': 'HELP',
\   'filename': 1,
\   'lineinfo': 1,
\   'percent': 1,
\  },
\ 'diff' : {
\   'mode': 'DIFF',
\  },
\ }

function! Lightline_field_enabled(field)
    exe 'let section_exist = exists("g:lightline_fields.' . &ft . '")'
    exe 'let field_enabled = exists("g:lightline_fields.' . &ft . '.' . a:field . '") && g:lightline_fields.' . &ft . '.' . a:field
    return field_enabled || !section_exist
endfunction

function! Lightline_get_field(field)
    exe 'let field_enabled = exists("g:lightline_fields.' . &ft . '.' . a:field . '")'
    if field_enabled
        exe 'let field = g:lightline_fields.' . &ft . '.' . a:field
        return field
    else
        return ""
endfunction

function! Lightline_encoding()
    return !Lightline_field_enabled("fileencoding") ? "" : &fenc !=# "" ? &fenc : &enc
endfunction

function! Lightline_percent()
    return !Lightline_field_enabled("percent") ? "" : printf("%2d%% \u2263", (100 * line('.') / line('$'))) 
endfunction

function! Lightline_lineinfo()
    return !Lightline_field_enabled("lineinfo") ? "" : printf("%3d:%-2d \ue0a1", line('.'), col('.'))
endfunction

function! Lightline_modified()
    let mode=lightline#mode()
    return mode ==? 'terminal' || !Lightline_field_enabled("modified") || !&modified ? "" : "\u2260"
endfunction

function! Lightline_readonly()
    let mode=lightline#mode()
    return mode ==? 'terminal' || !&readonly || &modifiable || !Lightline_field_enabled("readonly") ? "" : "\ue0a2"
endfunction

function! Lightline_gitbranch()
    if Lightline_field_enabled("gitbranch") 
        let branch = FugitiveHead()
        return branch !=# '' ? "\ue0a0 " . branch : ''
    endif
    return ""
endfunction

function! Lightline_mode()
    let mode = Lightline_get_field("mode")
    return strlen(mode) ? mode : lightline#mode()
endfunction

function! Lightline_filename()
    return exists("b:term_title") ? b:term_title :
    	\ Lightline_field_enabled("filename") ? expand('%:t') : ''
endfunction

function! Lightline_fileformat()
    return !Lightline_field_enabled("fileformat") ? '' :
        \ &fileformat ==# 'unix' ? 'Unix (LF)' :
        \ &fileformat ==# 'windows' ? 'Windows (CR LF)' :
        \ &fileformat
endfunction

function! Lightline_filetype()
    return !Lightline_field_enabled("filetype") ? '' : &filetype
endfunction

function! Lightline_tab_file_bufnr(n)
    let buflist = tabpagebuflist(a:n)
    for buf in buflist
        if filereadable(bufname(buf))
            return buf 
        endif
    endfor
    return buflist[tabpagewinnr(a:n) - 1]
endfunction

function! Lightline_tab_filename(n)
    let buflist = tabpagebuflist(a:n)
    let bufnr = Lightline_tab_file_bufnr(a:n)
    let tabname = ''
    let spaces = "               "
    
    if IsBufTerminal(bufnr)
        if !has('nvim')
            let tabname = term_gettitle(bufnr)
        else
            let tabname = getbufvar(bufnr, 'term_title')
        endif
    endif
    if tabname == ''
        let tabname = expand('#' . bufnr . ':t')
    endif
    if tabname == ''
        let tabname = "[No Name]"
    endif
    if len(tabname) > 15
        let tabname = strcharpart(tabname, 0, 6) . "..." . strcharpart(tabname, len(tabname) - 6, 6)
    elseif len(tabname) < 15
        let tabname = strcharpart(spaces, 0, float2nr(floor((15 - len(tabname))/2.0))) . tabname . strcharpart(spaces, 0, float2nr(ceil((15 - len(tabname))/2.0)))
    endif
    return tabname
endfunction

function! Lightline_tab_modified(n) abort
    let bufnr = Lightline_tab_file_bufnr(a:n)
    
    if IsBufTerminal(bufnr)
        return ''
    endif
    
    return getbufvar(bufnr, '&modified') ? "\u2260" : ''
endfunction

function! Lightline_tab_readonly(n) abort
    let bufnr = Lightline_tab_file_bufnr(a:n)
    
    if IsBufTerminal(bufnr)
        return ''
    endif

    return getbufvar(bufnr, '&readonly') || !getbufvar(bufnr, '&modifiable') ? "\ue0a2" : ''
endfunction

" Use autocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"SESSIONS

function! SessionCloseUnrestorableBuffs()
    for buf in range(1, bufnr('$'))
        let buffer_name = bufname(buf)
            if buffer_name =~# '\v(NERD_tree_*|__Tagbar__.*|undotree_*|diffpanel_*|\[BufExplorer\])'
                exe 'bw' . bufnr(buf)
            endif
    endfor
endfunction

" Like bufdo but restore the current buffer.
function! BufDo(command)
  let currBuff=bufnr("%")
  execute 'bufdo ' . a:command
  execute 'buffer ' . currBuff
endfunction
com! -nargs=+ -complete=command Bufdo call BufDo(<q-args>)

let s:sessionfile = getcwd() . '/session.vim'

function! SessionLoad()
	exe 'source ' . s:sessionfile
endfunction

autocmd sessionloadpost * call BufDo("if filereadable(bufname()) | call FugitiveDetect(bufname()) | endif")

function! SessionExist()
	return filereadable(s:sessionfile)
endfunction

function! SessionSave()
	call SessionCloseUnrestorableBuffs()
	set sessionoptions=localoptions,blank,curdir,folds,help,tabpages,winsize,terminal
	exe 'mksession! ' . s:sessionfile 
endfunction

function! DefaultWorkspace()
	"terminal
	"wincmd J
	"res12
	"wincmd k
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"LAYOUT

augroup layout_load
	autocmd vimenter * if SessionExist() | call SessionLoad() | else | call DefaultWorkspace() | endif
	autocmd vimenter * call lightline#update()
augroup end

augroup layout_save
	autocmd vimleavepre * if SessionExist() | call SessionSave() | endif
augroup end

""" ACK
" ack.vim --- {{{

" Use ripgrep for searching ⚡️
" Options include:
" --vimgrep -> Needed to parse the rg response properly for ack.vim
" --type-not sql -> Avoid huge sql file dumps as it slows down the search
" --smart-case -> Search case insensitive if all lowercase pattern, Search case sensitively otherwise
let g:ackprg = 'rg --no-ignore --vimgrep --max-depth=20 --type-not sql --smart-case'

" Auto close the Quickfix list after pressing '<enter>' on a list item
let g:ack_autoclose = 1

" Any empty ack search will search for the work the cursor is on
let g:ack_use_cword_for_empty_search = 1

" Don't jump to first match
cnoreabbrev Ack Ack!

" Maps <leader>/ so we're ready to type the search keyword
nnoremap <Leader>/ :Ack!<Space>
" }}}

" Navigate quickfix list with ease
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>

