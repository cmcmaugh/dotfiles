# In your home.nix or a separate vim.nix file
{ config, pkgs, lib, ... }:

{
  home.packages = [ pkgs.fzf ];

  programs.vim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      fzf-vim
      vim-tmux-navigator
      nerdtree
    ];

    # Settings from the exact supported list you provided.
    settings = {
      # From your list:
      backupdir = [ "~/.vimtmp//" ]; # Expects a list of strings
      expandtab = true;
      hidden = true;
      history = 1000;
      ignorecase = true;
      mouse = "a";
      number = true;
      shiftwidth = 2;
      smartcase = true;
      tabstop = 2;
      undodir = [ "~/.vimtmp//" ]; # Expects a list of strings
      undofile = true;
    };

    # extraConfig for ALL other settings, mappings, and commands.
    extraConfig = ''
      " Set the leader key
      let mapleader = ","

      " Enable filetype detection, plugins, and indentation
      filetype plugin indent on
      syntax on

      " --- All settings NOT on the supported 'settings' list ---
      set nocompatible
      set encoding=utf-8
      set ruler
      set showmatch
      set scrolloff=3
      set laststatus=2
      set title
      set incsearch
      set hlsearch
      set softtabstop=2
      set autoindent
      set smarttab
      " --- End of settings ---

      " Clear search highlight
      nnoremap <leader><space> :nohlsearch<CR>

      " Swap ; and :
      nnoremap ; :
      nnoremap : ;

      " Navigation mappings
      inoremap jk <Esc>
      nnoremap <tab> %
      vnoremap <tab> %

      " FZF mappings
      nnoremap <leader>f :Files<CR>
      nnoremap <leader>b :Buffers<CR>
      nnoremap <leader>g :Rg<CR>

      " Strip trailing whitespace on save
      autocmd BufWritePre * %s/\s\+$//e
    '';
  };
  home.activation.createVimDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.vimtmp
  '';
}
