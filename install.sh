#!/bin/bash
set -e

echo "🔗 Installing dotfiles..."

stow bash
stow vim
stow tmux
[ -d git ] && stow git
[ -d bin ] && stow bin

# Install vim-plug if not present
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  echo "🔌 Installing vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install Vim plugins
echo "📦 Installing Vim plugins..."
vim +PlugInstall +qall

# Install fzf CLI if not already installed
if [ ! -d ~/.fzf ]; then
  echo "🔍 Installing fzf CLI..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi

# Install ripgrep (for :Rg) if missing
if ! command -v rg >/dev/null 2>&1; then
  echo "📦 Installing ripgrep..."
  sudo apt-get update && sudo apt-get install -y ripgrep
fi

echo "✅ Dotfiles fully installed. Reload your shell or run: source ~/.bashrc"
