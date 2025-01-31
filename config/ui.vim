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

function! HideLeftPanes()
    for buf in range(1, bufnr('$'))
        if IsBufValid(buf) && IsBufLeftPane(buf) && IsBufVisible(buf)
            call HideBuf(buf)
        endif
    endfor
endfunction

function! HideOtherLeftPanes(bufnr)
    for buf in range(1, bufnr('$'))
        if IsBufValid(buf) && buf != a:bufnr && IsBufLeftPane(buf) && IsBufVisible(buf)
            call HideBuf(buf)
        endif
    endfor
endfunction

function! HideBottomPanes()
    for buf in range(1, bufnr('$'))
        if IsBufValid(buf) && IsBufBottomPane(buf) && IsBufVisible(buf)
            call HideBuf(buf)
        endif
    endfor
endfunction

function! HideOtherBottomPanes(bufnr)
    for buf in range(1, bufnr('$'))
        if IsBufValid(buf) && buf != a:bufnr && IsBufBottomPane(buf) && IsBufVisible(buf)
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
    return IsBufNERDTree(a:bufnr) || IsBufTagbar(a:bufnr) || IsBufUndotree(a:bufnr) || IsBufGitBlame(a:bufnr)
endfunction

function! IsFileType(bufnr, filetype)
    let filetype = getbufvar(a:bufnr, '&filetype', 'ERROR')
    return filetype == a:filetype
endfunction

function! IsBufNERDTree(bufnr)
    return IsFileType(a:bufnr, 'nerdtree')
endfunction

function! IsBufTagbar(bufnr)
    return IsFileType(a:bufnr, 'tagbar')
endfunction

function! IsBufUndotree(bufnr)
    return IsFileType(a:bufnr, 'undotree')
endfunction

function! IsBufGitBlame(bufnr)
    return IsFileType(a:bufnr, 'fugitiveblame')
endfunction


function! LeftPaneNERDTree(findfile)
    let bufnr = -1
    let filepath = expand('%:p')
    if exists('t:NERDTreeBufName')
        let bufnr = GetBufNrByName(t:NERDTreeBufName)
    endif
    if IsBufVisible(bufnr) && a:findfile == 0
        call HideBuf(bufnr)
    else
        call HideLeftPanes()
        "silent exe 'NERDTreeMirror'
        if !IsBufVisible(bufnr)
            NERDTreeFocus
        endif
        if a:findfile && filepath != ''
            silent exe 'NERDTreeFind ' . filepath
        endif
        for i in [1, 2, 3]
            if IsBufNERDTree(bufnr())
                silent exe 'vertical resize ' . g:leftPaneWidth
                set winfixbuf
                break
            endif
            echo "Timeout switching NERDTree " . i
            sleep 100m
        endfor
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
        call HideLeftPanes()
        TagbarOpen fj
        for i in [1, 2, 3]
            if IsBufTagbar(bufnr())
                silent exe 'vertical resize ' . g:leftPaneWidth
                set winfixbuf
                break
            endif
            echo "Timeout switching Tagbar " . i
            sleep 100m
        endfor
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
        call HideLeftPanes()
        UndotreeShow
        for i in [1, 2, 3]
            if IsBufUndotree(bufnr())
                silent exe 'vertical resize ' . g:leftPaneWidth
                set winfixbuf
                wincmd l
                wincmd h
                break
            endif
            echo "Timeout switching Undotree " . i
            sleep 100m
        endfor
    endif
endfunction

nmap <silent> <F2> :call LeftPaneNERDTree(0)<CR>
tmap <silent> <F2> <C-w>:call LeftPaneNERDTree(0)<CR>
nmap <silent> <F14> :call LeftPaneNERDTree(1)<CR>
nmap <silent> <F3> :call LeftPaneTagbar()<CR>
tmap <silent> <F3> <C-w>:call LeftPaneTagbar()<CR>
nmap <silent> <F4> :call LeftPaneUndotree()<CR>
tmap <silent> <F4> <C-w>:call LeftPaneUndotree()<CR>

"bottom pane

let g:bottomPaneHeight = 12

function! IsBufBottomPane(bufnr)
    return IsBufBufExplorer(a:bufnr) || IsBufQuickFix(a:bufnr) || IsBufTerminal(a:bufnr) || IsBufHelp(a:bufnr)
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
        call HideBottomPanes()
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

function! QuickFixToggle(diaglist)
    let bufnr = GetQuickFixBufNr()
    if IsBufVisible(bufnr)
        call HideBuf(bufnr)
    else
        call HideBottomPanes()
        if a:diaglist == 1
            lua vim.diagnostic.setloclist()
            "for all buffers
            "lua vim.diagnostic.setqflist()
        else
            silent exe 'copen ' . g:bottomPaneHeight
        endif
        if IsBufQuickFix(bufnr())
            silent exe 'resize ' . g:bottomPaneHeight
            set modifiable
            wincmd J
        endif
    endif
endfunction

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

nmap <silent> <F6> :call QuickFixToggle(0)<CR>
tmap <silent> <F6> <C-w>:call QuickFixToggle(0)<CR>
nmap <silent> <F18> :call QuickFixToggle(1)<CR>
tmap <silent> <F18> <C-w>:call QuickFixToggle(1)<CR>

"terminal pane

function! IsBufTerminal(buf)
    return getbufvar(a:buf, "pane") == "true" && getbufvar(a:buf, "term_title", "ERROR") != "ERROR"
endfunction

function! GetTerminalBufNr()
    if exists('t:term_bufnr') && IsBufTerminal(t:term_bufnr)
        return t:term_bufnr
    endif
    return -1 
endfunction

function! TerminalToggle()
    let term_bufnr = GetTerminalBufNr()

    if !HideBuf(term_bufnr)
        call HideBottomPanes()
        wincmd b
        if term_bufnr != -1
            silent exe g:bottomPaneHeight . 'split #' . term_bufnr
        else
            silent exe g:bottomPaneHeight . 'split term:///usr/bin/env bash'
            call nvim_buf_set_var(0, "pane", "true")
            set scrollback=100000
            exe 'let t:term_bufnr = ' . bufnr()
        endif
        set nonumber
        startinsert
        wincmd J
    endif
endfunction

nmap <silent> <F5> :call TerminalToggle()<CR>
tmap <silent> <F5> <C-w>:call TerminalToggle()<CR>
tmap <silent> <C-DEL> <C-w>:set scrollback=1 \| sleep 100m \| set scrollback=100000<CR>i

"terminal tab

function! OpenTerminal()
    $tabnew
    terminal
    setlocal nonumber
    startinsert
endfunction

nmap <silent> <F17> :call OpenTerminal()<CR>
tmap <silent> <F17> <C-w>:call OpenTerminal()<CR>

function! IsBufHelp(bufnr)
    return IsFileType(a:bufnr, 'help')
endfunction

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

"tab navigation
map <S-Tab> <C-w>:tabprev<CR>
"map <C-Tab> <C-w>:tabnext<CR>
tmap <S-Tab> <C-w>:tabprev<CR>
"tmap <C-Tab> <C-w>:tabnext<CR>

"window navigation
map <C-Up> <C-w>k
map <C-Down> <C-w>j
map <C-Left> <C-w>h
map <C-Right> <C-w>l
tmap <C-Up> <C-w>k
tmap <C-Down> <C-w>j
tmap <C-Left> <C-w>h
tmap <C-Right> <C-w>l

"window size
map <S-Up> <C-w>+
map <S-Down> <C-w>-
map <S-Left> <C-w><
map <S-Right> <C-w>>
tmap <S-Up> <C-w>+
tmap <S-Down> <C-w>-
tmap <S-Left> <C-w><
tmap <S-Right> <C-w>>

augroup ui
    autocmd! ui
    "quick fix autocmd
    "autocmd ui bufcreate * if IsBufQuickFix(bufnr()) | silent exe 'map <silent> <buffer> <CR> :.cc<CR>' | endif
    autocmd ui BufWinEnter * if IsBufQuickFix(bufnr()) | set modifiable | silent exe 'resize ' . g:bottomPaneHeight | endif
    autocmd ui BufEnter * if IsBufQuickFix(bufnr()) | call HideOtherBottomPanes(bufnr()) | endif

    "help pane autocmd
    autocmd ui BufWinEnter * if IsBufHelp(bufnr())  | silent exe 'resize ' . g:bottomPaneHeight | endif
    autocmd ui BufEnter * if IsBufHelp(bufnr()) | call HideOtherBottomPanes(bufnr()) | endif

    "gitblame pane autocmd
    autocmd ui BufWinEnter * if IsBufGitBlame(bufnr())  | silent exe 'vertical resize ' . g:leftPaneWidth | set winfixbuf | endif
    autocmd ui BufEnter * if IsBufGitBlame(bufnr()) | call HideOtherLeftPanes(bufnr()) | endif

    "autocmd ui BufWinEnter * if IsBufBottomPane(bufnr()) | silent exe 'resize ' . g:bottomPaneHeight | endif
    "autocmd ui TabLeave * call HideOtherPanes(-1)
    autocmd ui TabEnter * call HideNoNameBufs()

    "autocmd ui BufEnter * if IsBufLeftPane(bufnr()) | silent exe 'vertical resize ' . g:leftPaneWidth | endif
    autocmd ui BufWinLeave * let buf = bufnr() | if IsBufBottomPane(buf) | let g:bottomPaneHeight = winheight(bufwinnr(buf)) | endif
    autocmd ui BufWinLeave * let buf = bufnr() | if IsBufLeftPane(buf) | let g:leftPaneWidth = winwidth(bufwinnr(buf)) | endif
augroup END
