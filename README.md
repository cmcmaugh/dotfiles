# ❄️ Nix-Managed Dotfiles

A declarative, reproducible development environment managed by **Nix Home Manager**. This configuration runs on Ubuntu (and generic Linux) using Nix Flakes.

## ✨ Features

- **Core:** [Home Manager](https://github.com/nix-community/home-manager) + Nix Flakes.
- **Shell:** Zsh + Oh My Zsh + [Powerlevel10k](https://github.com/romkatv/powerlevel10k).
- **Editors:**
  - **VS Code:** Fully declarative configuration (settings, keybindings, and extensions managed via Nix). Includes Vim emulation.
  - **Vim:** Fast, customized configuration.
- **Terminal:** Alacritty + Tmux (with custom plugins & status bar).
- **Modern CLI Tools:**
  - `zoxide` (Smarter `cd`)
  - `eza` (Better `ls`)
  - `bat` (Better `cat`)
  - `lazygit` (Terminal Git UI)
  - `direnv` (Per-directory environment variables)
  - `fzf` & `ripgrep`

## 🛠️ Prerequisites

1.  **Install Nix:**
    ```bash
    sh <(curl -L https://nixos.org/nix/install) --daemon
    ```

2.  **Enable Flakes:**
    Edit `/etc/nix/nix.conf` or `~/.config/nix/nix.conf` and add:
    ```
    experimental-features = nix-command flakes
    ```

3.  **Install Home Manager (Standalone):**
    ```bash
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
    ```

## 🚀 Installation

1.  **Clone this repository:**
    ```bash
    git clone git@github.com:cmcmaugh/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

2.  **Apply the configuration:**
    *Note: The first run might take a while as it downloads VS Code and other tools.*
    ```bash
    home-manager switch --flake .#conor
    ```
    *(If you have existing config files causing conflicts, append `-b backup` to the command above).*

3.  **Log out and Log back in:**
    Required for Ubuntu/Linux to detect the `.desktop` files for Nix-installed apps (like VS Code) and to load session variables.

## 📂 Repository Structure

- **`flake.nix`**: The entry point. Defines the system architecture and allows "unfree" packages (required for VS Code/Copilot).
- **`home.nix`**: Main configuration file. Imports modules and installs core packages.
- **`vscode.nix`**: Declarative VS Code setup. **Note:** Settings here are read-only.
- **`vim.nix`**: Vim settings and plugins.
- **`tmux.nix`**: Tmux configuration and styling.
- **`zsh/`**: Zsh specific settings and Powerlevel10k config.

## ⚡ Workflow & Cheat Sheet

### Applying Changes
Whenever you edit a `.nix` file, run this to apply the changes:
```bash
home-manager switch --flake .#conor
```

### Disk Usage & Cleanup

Nix stores old versions of your profile so you can rollback. To free up space:
```
# Check usage
nix-tree

# Delete old generations
nix-collect-garbage -d
````

## 💡 Notes

* VS Code: Your settings.json is now read-only. To change a setting, edit vscode.nix and rebuild.
* Python/Java: This setup includes python3 and jdk17. direnv is configured to handle project-specific environments automatically.
* Vim Bindings: VS Code is configured with Vim keybindings.
    * jk -> <Esc> (Insert Mode)
    * ; <-> : swap (Normal/Visual Mode)

## Home drive building notes from old setup

These are for reference only

Copy all non-hidden directories
Copy .VirtualBox/*.xml

sudo apt-get install build-essential virtualbox wireshark nautilus-dropbox fonts-inconsolata
install the virtualbox extensions pack

.bash_history*
.gitconfig
.pylintrc
.pypirc
.pip/pip.conf

.aws-default
.ssh
.vim
.TinyCA

sudo usermod -a -G vboxusers $USER

Get following working:
Dropbox
Netbeans
