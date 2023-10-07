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

" Snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Completion type
Plug 'onsails/lspkind.nvim'

" Other
Plug 'majutsushi/tagbar'
Plug 'mbbill/undotree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dispatch'
Plug 'airblade/vim-gitgutter'
"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
"Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'itchyny/lightline.vim'

" Themes
"Plug 'NLKNguyen/papercolor-theme'
Plug 'lifepillar/vim-gruvbox8'

" Fuzzy find plugins
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.3' }
Plug 'BurntSushi/ripgrep'

Plug 'jlanzarotta/bufexplorer'
Plug 'peterhoeg/vim-qml'
Plug 'kergoth/vim-bitbake'
call plug#end()

source ~/.config/nvim/core.vim
source ~/.config/nvim/ui.vim
source ~/.config/nvim/line.vim

source ~/.config/nvim/find.lua
source ~/.config/nvim/lsp.lua
