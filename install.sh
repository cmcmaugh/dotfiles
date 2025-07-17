#!/bin/bash
set -e

# --- Helper Functions ---
install_package() {
  PACKAGE=$1
  if ! command -v "$PACKAGE" >/dev/null 2>&1; then
    echo "📦 Installing $PACKAGE..."
    sudo apt-get update && sudo apt-get install -y "$PACKAGE"
  else
    echo "✅ $PACKAGE is already installed."
  fi
}

echo "🚀 Starting dotfiles installation..."

# --- Package Installation ---
install_package "stow"
install_package "zsh"
install_package "tmux"
install_package "curl"
install_package "git"
install_package "ripgrep"
install_package "xclip"

# --- Zsh, Oh My Zsh, and Powerlevel10k ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🔌 Installing Oh My Zsh..."
  # The --unattended flag prevents the script from trying to change the shell or run zsh.
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "✅ Oh My Zsh is already installed."
fi

# Install Powerlevel10k theme
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "🎨 Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "✅ Powerlevel10k is already installed."
fi


# --- Stow Symlinks ---
echo "🔗 Creating symlinks with Stow..."
stow bash
stow vim
stow tmux
stow zsh
stow alacritty
[ -d git ] && stow git
[ -d bin ] && stow bin

# --- Tmux Plugin Manager (TPM) ---
if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "🔌 Installing Tmux Plugin Manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  echo "📦 Installing Tmux plugins..."
  (unset SSH_CLIENT; ~/.tmux/plugins/tpm/bin/install_plugins)
else
  echo "✅ TPM is already installed."
fi

# --- Vim-plug and FZF ---
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  echo "🔌 Installing vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "📦 Installing Vim plugins..."
vim +PlugInstall +qall

if [ ! -d ~/.fzf ]; then
  echo "🔍 Installing fzf CLI..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  # The install script handles setup for both bash and zsh
  ~/.fzf/install --all
else
    echo "✅ fzf is already installed."
fi

echo -e "\n\n✅ Dotfiles installation complete!"
echo " L Please change your default shell to Zsh manually by running:"
echo "   sudo chsh -s \$(which zsh) \$USER"
echo "   After that, log out and log back in for the change to take effect."
echo "   You can then run 'p10k configure' to customize your prompt."
