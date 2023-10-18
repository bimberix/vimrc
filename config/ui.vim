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
    for buf in range(1, bufnr('$'))
        let filetype = getbufvar(buf, '&filetype', 'ERROR')
        if filetype == 'nerdtree' && bufwinnr(buf) != -1 && a:opt !=# "nerdtree"
            NERDTreeToggle
        elseif filetype == 'tagbar' && bufwinnr(buf) != -1 && a:opt !=# "tagbar"
            TagbarToggle
        elseif filetype == 'undotree' && bufwinnr(buf) != -1 && a:opt !=# "undotree"
            UndotreeToggle
        endif
    endfor
endfunction

function! OldLeftPaneHideOther(opt)
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

" Navigate quickfix list with ease
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>

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
