#!/bin/bash
set -e

echo "🔗 Installing dotfiles..."

stow bash
stow vim
stow tmux
[ -d git ] && stow git
[ -d bin ] && stow bin

# install tmux tpm if not present
if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "🔌 Installing Tmux Plugin Manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install Tmux plugins
echo "📦 Installing Tmux plugins..."
# We unset SSH_CLIENT temporarily so tpm sources the "local" config,
# avoiding issues with the remote config in a non-interactive environment.
(unset SSH_CLIENT; ~/.tmux/plugins/tpm/bin/install_plugins)

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

# Install xclip (for tmux-yank clipboard integration)
if ! command -v xclip >/dev/null 2>&1; then
  echo "📦 Installing xclip..."
  sudo apt-get update && sudo apt-get install -y xclip
fi

echo "✅ Dotfiles fully installed. Reload your shell or run: source ~/.bashrc"
