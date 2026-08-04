" https://github.com/junegunn/vim-plug

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" LSP Support
Plug 'neovim/nvim-lspconfig'             " Required

" Other
Plug 'preservim/tagbar'
Plug 'mbbill/undotree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dispatch'
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdcommenter'

" File browser
Plug 'preservim/nerdtree'
Plug 'bimberix/nvim-dirdiff'


" Status line
Plug 'itchyny/lightline.vim'

" Themes
Plug 'lifepillar/vim-gruvbox8'

" Search plugins
Plug 'mileszs/ack.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Buffers
Plug 'jlanzarotta/bufexplorer'

" Syntax
Plug 'peterhoeg/vim-qml'
Plug 'kergoth/vim-bitbake'
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'evanleck/vim-svelte', {'branch': 'main'}
call plug#end()

source ~/.config/nvim/custom.lua
source ~/.config/nvim/core.vim
source ~/.config/nvim/ui.vim
source ~/.config/nvim/line.vim

source ~/.config/nvim/find.vim
source ~/.config/nvim/lsp.lua
