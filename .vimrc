if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'majutsushi/tagbar'
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'mbbill/undotree'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
"Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'itchyny/lightline.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'lifepillar/vim-gruvbox8'
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
set nowrap
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
"set updatetime=300
"
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Recently vim can merge signcolumn and number column into one
set signcolumn=number

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"KEY MAPPINGS

"left pane
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
    if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) == -1
        NERDTreeFocus
    elseif exists("t:NERDTreeBufName")
        NERDTreeToggle
    else
        if filereadable(bufname())
            NERDTreeFind
        else
            NERDTree
        endif
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
    if exists("t:undotree") && t:undotree.IsVisible()
        UndotreeToggle
    elseif exists("t:undotree")
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

"terminal pane
function! GetTerminalBufNr()
    for buf in range(1, bufnr('$'))
        let buffer_name = bufname(buf)
        if buffer_name =~# '\v(!/bin/bash*)'
            return bufnr(buf)
        endif
    endfor
    return 0 
endfunction

function! TerminalToggle()
    let term_bufnr = GetTerminalBufNr()
    if term_bufnr && bufwinnr(term_bufnr) != -1
        exe bufwinnr(term_bufnr) . 'hide'
        return
    endif
    wincmd b 
    if term_bufnr
        exe 'split #' . term_bufnr
    else
        terminal
    endif
    resize 12
endfunction

nmap <silent> <F5> :call TerminalToggle()<CR>
tmap <silent> <F5> <C-w>:call TerminalToggle()<CR>
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
tnoremap <silent> <A-Left> <C-w>N:execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
tnoremap <silent> <A-h> <C-w>N:execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
tnoremap <silent> <A-Right> <C-w>N:execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
tnoremap <silent> <A-l> <C-w>N:execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <A-h> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
nnoremap <silent> <A-l> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>

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

map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

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
"NERD TREE

let NERDTreeShowHidden = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"TAGBAR
let g:tagbar_left = 1
let g:tagbar_width = 31
let g:tagbar_compact = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"UNDOTREE
let g:undotree_SplitWidth = 31
let g:undotree_HelpLine = 0
let g:undotree_SetFocusWhenToggle = 1
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
\      'left': [ [ 'filename' ] ],
\     'right': [ [ 'lineinfo' ],
\                [ 'percent' ] ]
\ },
\ 'tabline' : {
\     'left': [ [ 'tabs' ] ],
\    'right': [ [ 'close' ],
\               [ 'cocstatus' ] ]
\ },
\ 'component' : {
\    'align': '%<'
\ },
\ 'component_function': {
\   'gitbranch': 'LightlineFugitive',
\   'readonly': 'LightlineReadonly',
\   'mode': 'LightlineMode',
\   'modified': 'LightlineModified',
\   'filename': 'LightlineFilename',
\   'cocstatus': 'coc#status',
\   'fileformat': 'LightlineFileformat',
\   'filetype': 'LightlineFiletype',
\   'lineinfo': 'LightlineLineinfo',
\   'percent': 'LightlinePercent',
\   'fileencoding': 'LightlineEncoding',
\ },
"\ 'separator': { 'left': "\ue0b8", 'right': "\ue0ba" },
"\ 'subseparator': { 'left': "\ue0b9", 'right': "\ue0bb" }
\ }


let g:lightlinefields = {
\ 'nerdtree' : {
\   'gitbranch': 0,
\   'readonly': 0,
\   'mode': 0,
\   'modified': 0,
\   'filename': 0,
\   'cocstatus': 0,
\   'fileformat': 0,
\   'filetype': 0,
\   'lineinfo': 0,
\   'percent': 0,
\   'fileencoding': 0,
\  },
\ 'tagbar' : {
\   'gitbranch': 0,
\   'readonly': 0,
\   'mode': 0,
\   'modified': 0,
\   'filename': 0,
\   'cocstatus': 0,
\   'fileformat': 0,
\   'filetype': 0,
\   'lineinfo': 0,
\   'percent': 0,
\   'fileencoding': 0,
\  },
\ 'undotree' : {
\   'gitbranch': 0,
\   'readonly': 0,
\   'mode': 0,
\   'modified': 0,
\   'filename': 0,
\   'cocstatus': 0,
\   'fileformat': 0,
\   'filetype': 0,
\   'lineinfo': 0,
\   'percent': 0,
\   'fileencoding': 0,
\  },
\ 'help' : {
\   'gitbranch': 0,
\   'readonly': 0,
\   'mode': 0,
\   'modified': 0,
\   'filename': 0,
\   'cocstatus': 0,
\   'fileformat': 0,
\   'filetype': 0,
\   'lineinfo': 0,
\   'percent': 0,
\   'fileencoding': 0,
\  },
\ 'diff' : {
\   'gitbranch': 0,
\   'readonly': 0,
\   'mode': 0,
\   'modified': 0,
\   'filename': 0,
\   'cocstatus': 0,
\   'fileformat': 0,
\   'filetype': 0,
\   'lineinfo': 0,
\   'percent': 0,
\   'fileencoding': 0,
\  },
\ }

function! s:lightline_field_disabled(field)
    exe 'let fielddisabled = exists("g:lightlinefields.' . &ft . '.' . a:field . '") && !g:lightlinefields.' . &ft . '.' . a:field
    return fielddisabled
endfunction

function! LightlineEncoding()
    return s:lightline_field_disabled("fileencoding") ? "" : &fenc !=# "" ? &fenc : &enc
endfunction

function! LightlinePercent()
    return s:lightline_field_disabled("percent") ? "" : (100 * line('.') / line('$')) . '%' . " \u2263" 
endfunction

function! LightlineLineinfo()
    return s:lightline_field_disabled("lineinfo") ? "" : printf("%d\ue0a1 %d\ue0a3", line('.'), col('.'))
endfunction

function! LightlineModified()
	let mode=lightline#mode()
	return mode ==? 'terminal' || s:lightline_field_disabled("modified") ? "" : &modified ? "\u2260" : &modifiable ? "" : "-"
endfunction

function! LightlineReadonly()
	return &readonly && !s:lightline_field_disabled("readonly") ? "\ue0a2" : ''
endfunction

function! LightlineFugitive()
    let path = bufname()
    if !s:lightline_field_disabled("gitbranch") 
        let branch = FugitiveHead()
        return branch !=# '' ? "\ue0a0 " . branch : ''
    endif
    return ""
endfunction

function! LightlineMode()
    return expand('%:t') =~# '^__Tagbar__' ? 'TAGBAR':
        \ expand('%:t') ==# 'ControlP' ? 'CtrlP' :
        \ &filetype ==# 'nerdtree' ? 'EXPLORE' :
        \ &filetype ==# 'undotree' ? 'UNDOTREE' :
        \ &filetype ==# 'diff' ? 'DIFF' :
        \ lightline#mode()
endfunction

function! LightlineFilename()
    return s:lightline_field_disabled("filename") ? '' : expand('%:t')
endfunction

function! LightlineFileformat()
    return s:lightline_field_disabled("fileformat") ? '' :
        \ &fileformat ==# 'unix' ? 'Unix (LF)' :
        \ &fileformat ==# 'windows' ? 'Windows (CR LF)' :
        \ &fileformat
endfunction

function! LightlineFiletype()
	return s:lightline_field_disabled("filetype") ? '' : &filetype
endfunction

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"SESSIONS

function! SessionCloseUnrestorableBuffs()
for buf in range(1, bufnr('$'))
    let buffer_name = bufname(buf)
        if buffer_name =~# '\v(NERD_tree_*|__Tagbar__.*|undotree_*|diffpanel_*)'
            exe 'bw' . bufnr(buf)
        endif
    endfor
endfunction

let s:sessionfile = getcwd() . '/session.vim'

function! SessionLoad()
	exe 'source ' . s:sessionfile
endfunction

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
