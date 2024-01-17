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
Plug 'ray-x/lsp_signature.nvim'
Plug 'windwp/nvim-autopairs'

" Snippets
Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'}
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'honza/vim-snippets'

" Other
Plug 'majutsushi/tagbar'
Plug 'mbbill/undotree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dispatch'
Plug 'airblade/vim-gitgutter'
"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdcommenter'

" File browser
Plug 'preservim/nerdtree'
Plug 'bimberix/nvim-dirdiff'


" Status line
Plug 'itchyny/lightline.vim'

" Themes
"Plug 'NLKNguyen/papercolor-theme'
Plug 'lifepillar/vim-gruvbox8'

" Fuzzy find plugins
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'BurntSushi/ripgrep'

" Buffers
Plug 'jlanzarotta/bufexplorer'

" Syntax
Plug 'peterhoeg/vim-qml'
Plug 'kergoth/vim-bitbake'
call plug#end()

source ~/.config/nvim/core.vim
source ~/.config/nvim/ui.vim
source ~/.config/nvim/line.vim

source ~/.config/nvim/find.lua
source ~/.config/nvim/lsp.lua
