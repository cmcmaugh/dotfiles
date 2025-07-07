" Minimal .vimrc for terminal purist

set nocompatible
filetype plugin indent on
syntax on
set encoding=utf-8
let mapleader = ","

" UI
set number
set ruler
set showmatch
set scrolloff=3
set laststatus=2
set title
set mouse=a

" Search
set incsearch
set ignorecase
set smartcase
set hlsearch
nnoremap <leader><space> :nohlsearch<CR>

" Indentation
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set autoindent
set smarttab

" File handling
set hidden
set backupdir=~/.vimtmp//
set undodir=~/.vimtmp//
set undofile
set history=1000
autocmd BufWritePre * %s/\s\+$//e



nnoremap ; :
nnoremap : ;

" Navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
inoremap jk <Esc>
nnoremap <tab> %
vnoremap <tab> %


" fzf
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

" Plugins (optional)
call plug#begin('~/.vim/plugged')
" Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
call plug#end()
"
