"panes

function! IsBufVisible(buf)
    return a:buf != -1 && bufwinnr(a:buf) != -1
endfunction

function! IsBufValid(buf)
    return nvim_buf_is_valid(a:buf)
endfunction

function! IsBufEmpty(buf)
    return nvim_buf_get_name(a:buf) == "" && nvim_buf_line_count(a:buf)
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
"let NERDTreeCustomOpenArgs={'file':{'where': 't', 'reuse': 'all'}}

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

function! HideOtherPanes(bufnr)
    for buf in range(1, bufnr('$'))
        if IsBufValid(buf) && buf != a:bufnr && (IsBufBottomPane(buf) || IsBufLeftPane(buf)) && IsBufVisible(buf)
            call HideBuf(buf)
        endif
    endfor
endfunction

function! HideNoNameBufs()
    for buf in range(1, bufnr('$'))
        if IsBufValid(buf) && IsBufEmpty(buf)
            call HideBuf(buf)
        endif
    endfor
endfunction

function! IsBufLeftPane(bufnr)
    return IsBufNERDTree(a:bufnr) || IsBufTagbar(a:bufnr) || IsBufUndotree(a:bufnr)
endfunction

function! IsBufNERDTree(bufnr)
    let filetype = getbufvar(a:bufnr, '&filetype', 'ERROR')
    return filetype == 'nerdtree'
endfunction

function! IsBufTagbar(bufnr)
    let filetype = getbufvar(a:bufnr, '&filetype', 'ERROR')
    return filetype == 'tagbar'
endfunction

function! IsBufUndotree(bufnr)
    let filetype = getbufvar(a:bufnr, '&filetype', 'ERROR')
    return filetype == 'undotree'
endfunction

function! LeftPaneNERDTree()
    let bufnr = -1
    if exists('t:NERDTreeBufName')
        let bufnr = GetBufNrByName(t:NERDTreeBufName)
    endif
    if IsBufVisible(bufnr)
        call HideBuf(bufnr)
    else
        call HideOtherPanes(bufnr)
        silent exe 'NERDTreeMirror'
        if !IsBufVisible(bufnr)
            NERDTreeFocus
        endif
        silent exe 'vertical resize ' . g:leftPaneWidth
    endif
    call lightline#update()
endfunction

function! LeftPaneTagbar()
    let g:tagbar_width = g:leftPaneWidth
    let bufnr = -1
    if exists('t:tagbar_buf_name')
        let bufnr = GetBufNrByName(t:tagbar_buf_name)
    endif
    if IsBufVisible(bufnr)
        call HideBuf(bufnr)
    else
        call HideOtherPanes(bufnr)
        TagbarOpen fj
        silent exe 'vertical resize ' . g:leftPaneWidth
    endif
    call lightline#update()
endfunction

function! LeftPaneUndotree()
    let g:undotree_SplitWidth = g:leftPaneWidth
    let bufnr = -1
    if exists('t:undotree') && exists('t:undotree.bufname')
        let bufnr = GetBufNrByName(t:undotree.bufname)
    endif
    if IsBufVisible(bufnr)
        call HideBuf(bufnr)
    else
        call HideOtherPanes(bufnr)
        UndotreeShow
        silent exe 'vertical resize ' . g:leftPaneWidth
        wincmd l
        wincmd h
    endif
endfunction

nmap <silent> <F2> :call LeftPaneNERDTree()<CR>
tmap <silent> <F2> <C-w>:call LeftPaneNERDTree()<CR>
nmap <silent> <F14> :NERDTreeFind<CR>
nmap <silent> <F3> :call LeftPaneTagbar()<CR>
tmap <silent> <F3> <C-w>:call LeftPaneTagbar()<CR>
nmap <silent> <F4> :call LeftPaneUndotree()<CR>
tmap <silent> <F4> <C-w>:call LeftPaneUndotree()<CR>

autocmd TabLeave * call HideOtherPanes(-1)
autocmd TabEnter * call HideNoNameBufs()

"autocmd BufEnter * if IsBufLeftPane(bufnr()) | silent exe 'vertical resize ' . g:leftPaneWidth | endif
autocmd BufLeave * let buf = bufnr() | if IsBufLeftPane(buf) | let g:leftPaneWidth = winwidth(bufwinnr(buf)) | endif

"bottom pane

let g:bottomPaneHeight = 12

function! IsBufBottomPane(bufnr)
    return IsBufBufExplorer(a:bufnr) || IsBufQuickFix(a:bufnr) || IsBufTerminal(a:bufnr)
endfunction

"buflist pane
let g:bufExplorerSplitHorzSize = g:bottomPaneHeight
let g:bufExplorerDisableDefaultKeyMapping = 1
let g:bufExplorerDefaultHelp = 0

function! IsBufBufExplorer(buf)
    return bufname(a:buf) == '[BufExplorer]'
endfunction

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
        call HideOtherPanes(bufnr)
        wincmd b
        let g:bufExplorerSplitHorzSize = g:bottomPaneHeight
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
        call HideBuf(bufnr)
    else
        call HideOtherPanes(bufnr)
        lua vim.diagnostic.setqflist()
        if IsBufQuickFix(bufnr())
            silent exe 'resize ' . g:bottomPaneHeight
            set modifiable
        endif
    endif


    "if IsBufVisible(bufnr)
        "cclose
    "else
        "call HideOtherPanes(bufnr)
        "silent exe 'copen ' . g:bottomPaneHeight
        "set ma
        "wincmd J
    "endif
endfunction

"autocmd bufcreate * if IsBufQuickFix(bufnr()) | silent exe 'map <silent> <buffer> <CR> :.cc<CR>' | endif
"autocmd BufCreate,BufEnter * if IsBufQuickFix(bufnr()) | silent exe 'set modifiable' | endif
"autocmd BufWinEnter * if IsBufBottomPane(bufnr()) | silent exe 'resize ' . g:bottomPaneHeight | endif
autocmd BufLeave * if IsBufBottomPane(bufnr()) | let g:bottomPaneHeight = winheight(bufwinnr(bufnr())) | endif

" Navigate quickfix list with ease
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>

function! MyMake(task)
    "call BottomPaneHideOther("quickfix")
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

function! IsBufTerminal(buf)
    return getbufvar(a:buf, "pane") == "true" && getbufvar(a:buf, "term_title", "ERROR") != "ERROR"
endfunction

function! GetTerminalBufNr()
    for buf in range(1, bufnr('$'))
        if IsBufTerminal(buf) 
            return buf
        endif
    endfor
    return -1 
endfunction

function! TerminalToggle()
    let term_bufnr = GetTerminalBufNr()

    if !HideBuf(term_bufnr)
        call HideOtherPanes(term_bufnr)
        wincmd b
        if term_bufnr != -1
            silent exe g:bottomPaneHeight . 'split #' . term_bufnr
        else
            silent exe g:bottomPaneHeight . 'split term:///usr/bin/env bash'
            call nvim_buf_set_var(0, "pane", "true")
        endif
        set nonumber
        startinsert
    endif
endfunction

nmap <silent> <F5> :call TerminalToggle()<CR>
tmap <silent> <F5> <C-w>:call TerminalToggle()<CR>

"autocmd tableave * call BottomPaneHideOther(-1) 

"terminal tab

function! OpenTerminal()
    $tabnew
    terminal
    setlocal nonumber
    startinsert
endfunction

nmap <silent> <F17> :call OpenTerminal()<CR>
tmap <silent> <F17> <C-w>:call OpenTerminal()<CR>

"midnight commander

function! OpenMC()
    let name = "midnight_commander"
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
    call termopen('mc --skin=gotar')
    setlocal nonumber
    startinsert
    call nvim_buf_set_name(0, name)
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
