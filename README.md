# 🛠️ dotfiles

Terminal-purist dotfiles using [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks. This setup uses Zsh, Oh My Zsh, and the Powerlevel10k theme for a modern and efficient command-line experience.

## ✨ Features

- **Shell:** Zsh + Oh My Zsh + Powerlevel10k
- **Multiplexer:** Tmux with a custom, plugin-rich configuration
- **Editor:** Vim with essential plugins managed by `vim-plug`
- **Symlink Management:** GNU Stow
- **Other Tools:** fzf, ripgrep, and more.

## ✅ Prerequisites

- `git`
- `stow`
- `zsh`
- `tmux`
- A [Nerd Font](https://www.nerdfonts.com/) (e.g., MesloLGS NF) installed on your local machine for Powerlevel10k icons to render correctly.

## 🚀 Installation

1.  **Clone the repository:**
    ```sh
    git clone git@github.com:cmcmaugh/dotfiles.git ~/dotfiles
    ```

2.  **Run the installer:**
    ```sh
    cd ~/dotfiles
    ./install.sh
    ```

3.  **Change your default shell to Zsh:**
    The installer will prompt you to do this. You'll need to run the following command and enter your password:
    ```sh
    chsh -s $(which zsh)
    ```
    After running this command, **log out and log back in** for the changes to take effect.

4.  **(Optional) Configure Powerlevel10k:**
    The first time you start Zsh, Powerlevel10k's configuration wizard should launch automatically. If it doesn't, you can run it manually:
    ```sh
    p10k configure
    ```
    This will walk you through customizing your prompt's appearance. The settings will be saved to `~/.p10k.zsh`, which is symlinked from this repository.

## 📦 What's Included?

- **Zsh (`zsh/`):** Configuration for Oh My Zsh, Powerlevel10k theme, plugins, aliases, and history.
- **Bash (`bash/`):** A basic `.bashrc` for compatibility.
- **Vim (`vim/`):** A minimal and fast `.vimrc` with `vim-plug`.
- **Tmux (`tmux/`):** A highly customized `.tmux.conf` with plugins via TPM.
- **Git:** A global `.gitignore` file.