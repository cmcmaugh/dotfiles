
#!/bin/bash
set -e

echo "🔗 Installing dotfiles..."
stow bash
stow vim
stow tmux

# Install vim-plug if not present
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  echo "🔌 Installing vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install Vim plugins
echo "📦 Installing Vim plugins..."
vim +PlugInstall +qall

echo "✅ Dotfiles installed."
