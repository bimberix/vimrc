if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'majutsushi/tagbar'
"Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'frazrepo/vim-rainbow'
Plug 'mbbill/undotree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dispatch'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
"Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'itchyny/lightline.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'lifepillar/vim-gruvbox8'
Plug 'mileszs/ack.vim'
Plug 'jlanzarotta/bufexplorer'
"Plug 'Shougo/unite.vim'
"Plug 'jeetsukumaran/vim-buffergator'
"Plug 'roblillack/vim-bufferlist'
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
set makeprg=mymake

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
set signcolumn=number

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"KEY MAPPINGS

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
        if bufname(buf) == a:name
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
            call BufExplorerToggle2()
            silent exe 'bd ' . buf
        elseif getbufvar(buf, 'current_syntax') == 'qf' && a:opt !=# "quickfix"
            call HideBuf(buf)
        elseif bufname(buf) == '!/bin/bash' && a:opt !=# "terminal"
            call HideBuf(buf)
        endif
    endfor
endfunction

"buflist pane
let g:bufExplorerSplitHorzSize = g:bottomPaneHeight
let g:bufExplorerDisableDefaultKeyMapping = 1
let g:bufExplorerDefaultHelp = 0

function! BufExplorerToggle2()
    let bufnr = GetBufNrByName('[BufExplorer]')
    if !HideBuf(bufnr)
        call BottomPaneHideOther("bufexplorer")
        wincmd b
        BufExplorerHorizontalSplit
        if !IsBufVisible(bufnr)
            silent exe 'split #' . bufnr
            call HideBuf(bufnr)
            BufExplorerHorizontalSplit
        endif
    endif
endfunction

nmap <silent> <F7> :call BufExplorerToggle2()<CR>
tmap <silent> <F7> <C-w>:call BufExplorerToggle2()<CR>

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
    endif
endfunction

autocmd bufcreate * if IsBufQuickFix(bufnr()) | silent exe 'map <silent> <buffer> <CR> :.cc<CR>' | endif

function! Run(task)
    call BottomPaneHideOther("quickfix")
    silent exe 'Make! ' . a:task
    Copen!
    silent exe bufwinnr(GetQuickFixBufNr()) . 'resize ' . g:bottomPaneHeight
endfunction

command! -nargs=* Run call Run("<args>")

nmap <F10> :Run<SPACE>
tmap <F10> <C-w>:Run<SPACE>

nmap <silent> <F6> :call QuickFixToggle()<CR>
tmap <silent> <F6> <C-w>:call QuickFixToggle()<CR>

"terminal pane
function! TerminalToggle()
    let term_bufnr = GetBufNrByName('!/bin/bash')
    if !HideBuf(term_bufnr)
        call BottomPaneHideOther("terminal")
        wincmd b
        if term_bufnr != -1
            silent exe 'split #' . term_bufnr
        else
            terminal
        endif
        silent exe 'resize ' . g:bottomPaneHeight
    endif
endfunction

nmap <silent> <F5> :call TerminalToggle()<CR>
tmap <silent> <F5> <C-w>:call TerminalToggle()<CR>

autocmd tableave * call BottomPaneHideOther("") 

"midnight commander

function! OpenMC()
    let name = "Midnigth Commander"
    let bufnr = GetBufNrByName(name)
    
    if bufnr != -1
        for i in range(tabpagenr("$"))
            if index(tabpagebuflist(i + 1), bufnr) != -1
                silent exe "tabnext " . (i + 1)
                return
            endif
        endfor
        silent exe "tabnew | buffer " . bufnr
        return
    endif

    tabnew
    call term_start('mc --skin=darkfar', {'term_name': name, 'term_finish': 'close', 'curwin': 1, 'norestore': 1})
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
tmap <PageUp> <C-w>N<PageUp>

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
set background=dark
colorscheme PaperColor
hi LspCxxHlGroupMemberVariable ctermfg=Brown
hi link CocWarningSign WarningMsg
hi CocErrorSign ctermfg=Red
hi link markdownError NONE

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"NERD COMMENTER

filetype plugin on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"LIGHTLINE
let g:lightline = {
\ 'active': {
\   'left': [ [ 'mode', 'paste' ],
\             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
\  'right': [ [ 'lineinfo' , 'align' ],
\             [ 'percent' ],
\             [ 'fileformat', 'fileencoding', 'filetype' ] ]
\ },
\ 'inactive' : {
\      'left': [ [ 'gitbranch', 'filename' ] ],
\     'right': [ [ 'lineinfo' ],
\                [ 'percent' ] ]
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
    return !Lightline_field_enabled("lineinfo") ? "" : printf("%3d\ue0a1 %3d\ue0a3", line('.'), col('.'))
endfunction

function! Lightline_modified()
    let mode=lightline#mode()
    return mode ==? 'terminal' || !Lightline_field_enabled("modified") ? "" : &modified ? "\u2260" : &modifiable ? "" : "-"
endfunction

function! Lightline_readonly()
    return &readonly && Lightline_field_enabled("readonly") ? "\ue0a2" : ''
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
    return !Lightline_field_enabled("filename") ? '' : expand('%:t')
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
    let _ = expand('#'.Lightline_tab_file_bufnr(a:n).':t')
  return _ !=# '' ? _ : '[No Name]'
endfunction

function! Lightline_tab_modified(n) abort
    return getbufvar(Lightline_tab_file_bufnr(a:n), '&modified') ? "\u2260" : getbufvar(Lightline_tab_file_bufnr(a:n), '&modifiable') ? '' : '-'
endfunction

function! Lightline_tab_readonly(n) abort
  return getbufvar(Lightline_tab_file_bufnr(a:n), '&readonly') ? "\ue0a2" : ''
endfunction

" Use auocmd to force lightline update.
autocmd User CocStatusChinge,CocDiagnosticChange call lightline#update()

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
	terminal
	wincmd J
	res12
	wincmd k
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"COC

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <C-k> to trigger completion.
inoremap <silent><expr> <C-k> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd :call CocAction('jumpDefinition', 'tab drop')<CR>
nmap <silent> gy :call CocAction('jumpTypeDefinition', 'tab drop')<CR>
nmap <silent> gi :call CocAction('jumpImplementation', 'tab drop')<CR>
nmap <silent> gr :call CocAction('jumpReferences', 'tab drop')<CR>

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
"set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

""" ACK
" ack.vim --- {{{

" Use ripgrep for searching ⚡️
" Options include:
" --vimgrep -> Needed to parse the rg response properly for ack.vim
" --type-not sql -> Avoid huge sql file dumps as it slows down the search
" --smart-case -> Search case insensitive if all lowercase pattern, Search case sensitively otherwise
let g:ackprg = 'rg --vimgrep --type-not sql --smart-case'

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

