set laststatus=2

function! IsBufTerminal(bufnr)
    return '' != getbufvar(a:bufnr, 'term_title')
endfunction

let g:tablinesize = 30

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
\    'right': [ [ 'close' ] ]
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
    if len(tabname) > g:tablinesize
        let tabname = strcharpart(tabname, 0, g:tablinesize - 6) . "~" . strcharpart(tabname, len(tabname) - 5, 5)
    elseif len(tabname) < g:tablinesize
        let tabname = strcharpart(spaces, 0, float2nr(floor((g:tablinesize - len(tabname))/2.0))) . tabname . strcharpart(spaces, 0, float2nr(ceil((g:tablinesize - len(tabname))/2.0)))
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
