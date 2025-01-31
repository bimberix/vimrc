"let g:ackprg = 'rg --vimgrep --type-not sql --smart-case'
let g:ackprg = 'ack'

" Auto close the Quickfix list after pressing '<enter>' on a list item
"let g:ack_autoclose = 1

" Any empty ack search will search for the work the cursor is on
"let g:ack_use_cword_for_empty_search = 1

" Don't jump to first match
"cnoreabbrev Ack Ack!

nnoremap <leader>fg :Ack!<Space>
nnoremap <leader>ff :AckFile!<Space>



" Navigate quickfix list with ease
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>
