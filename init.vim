" https://github.com/junegunn/vim-plug

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" LSP Support
Plug 'neovim/nvim-lspconfig'             " Required

" Autocompletion
Plug 'hrsh7th/nvim-cmp'         " Required
Plug 'hrsh7th/cmp-nvim-lsp'     " Required

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

Plug 'majutsushi/tagbar'
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
Plug 'peterhoeg/vim-qml'
Plug 'kergoth/vim-bitbake'
call plug#end()

source ~/.config/nvim/new.lua
source ~/.config/nvim/old.vim
