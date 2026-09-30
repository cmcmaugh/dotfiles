# ❄️ Nix-Managed Dotfiles

A declarative, reproducible development environment managed by **Nix Home Manager**. This configuration runs on Ubuntu (and generic Linux) using Nix Flakes.

## ✨ Features

- **Core:** [Home Manager](https://github.com/nix-community/home-manager) + Nix Flakes.
- **Shell:** Zsh + Oh My Zsh + [Powerlevel10k](https://github.com/romkatv/powerlevel10k).
- **Editors:**
  - **VS Code:** Fully declarative configuration (settings, keybindings, and extensions managed via Nix). Includes Vim emulation.
  - **Vim:** Fast, customized configuration.
- **Terminal:** Alacritty + Tmux (with custom plugins & status bar).
- **CLI Tools:** `git`, `curl`, `uv`, `rsync`, `wget`, `ripgrep`, `tree`, `fzf`, `yq`, OpenTofu, AWS CLI, Node.js, Python tooling, Java, and Codex.

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

No channel-based Home Manager setup is required; this repository is applied through the flake.

## 🚀 Installation

1.  **Clone this repository:**
    ```bash
    git clone git@github.com:cmcmaugh/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

2.  **Apply the configuration:**
    *Note: The first run might take a while as it downloads VS Code and other tools.*
    ```bash
    nix run github:nix-community/home-manager -- switch --flake .#conor
    ```
    After the first successful switch, `home-manager` is installed and can be used directly:
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

### Spotify Player

This config installs the terminal client `spotify_player` and `playerctl`.

First-time setup:
```bash
home-manager switch --flake .#conor
spotify_player authenticate
spotify_player
```

If authentication succeeds but playback does not start, make sure a Linux audio
session is available on the host (for example PipeWire or PulseAudio).

### Shell Helpers

Interactive zsh shells optionally export `SAFETY_API_KEY` from
`$HOME/.config/safety/api-key`. The file is read at runtime and must stay outside
this repository and the Nix store; do not add its contents to Nix configuration
or `home.sessionVariables`.

To populate or replace it, run this command and paste the key at the hidden
prompt. The key itself is not entered as a command or saved in shell history.
The directory is private and the file is created with mode `0600`.

```bash
bash <<'BASH'
set +x
set -eu
umask 077
install -d -m 700 "$HOME/.config/safety"
key_file=$(mktemp "$HOME/.config/safety/.api-key.XXXXXX")
trap 'rm -f "$key_file"' EXIT
IFS= read -r -s -p 'Safety API key: ' safety_key </dev/tty
printf '\n' >/dev/tty
test -n "$safety_key"
printf '%s\n' "$safety_key" > "$key_file"
unset safety_key
chmod 600 "$key_file"
mv -fT "$key_file" "$HOME/.config/safety/api-key"
BASH
```

After applying Home Manager, open a new shell. Check the export without showing
its value (the command also avoids the automatic tmux launcher):

```bash
env -u SAFETY_API_KEY TERM_PROGRAM=vscode zsh -ic \
  'sh -c '\''test -n "$SAFETY_API_KEY"'\'' && echo "SAFETY_API_KEY is set and exported"'
stat -c '%a %U %n' "$HOME/.config/safety/api-key"
```

If the file is absent, startup continues normally without setting the variable.

Some small convenience helpers are configured by default:

- `terraform` -> `tofu`
- `tf12` runs `terraform-1.2.7`
- `toxu` runs `tox` against the system Python environment
- `mkve310`, `mkve38`, `mkve312` create virtualenvs under `~/venv/`
- `rmve <name>` removes a virtualenv from `~/venv/`
- `ec2connect <name>` opens a new tmux window and SSHes to the host resolved by `ec2-host`
- `slcodeartifact` enables uv's CodeArtifact keyring authentication and clears any old password export; interactive zsh runs it automatically

Home Manager installs `keyring` with a pinned `keyrings.codeartifact` plugin and
enables uv's subprocess keyring provider. Projects using the
`codeartifact-sensorlog` index obtain tokens on demand using your AWS credentials;
no CodeArtifact token is stored in a shell environment variable. This follows
[uv's CodeArtifact integration](https://docs.astral.sh/uv/guides/integration/aws/).

After switching from the old token helper, open a new terminal and restart
long-running tools once to discard inherited password variables. For an existing
zsh shell, run `source ~/.config/zsh/extra.zsh`. AWS credentials must remain valid;
if an AWS SSO session expires, renew it with `aws sso login --profile <profile>`.
Select a non-default AWS profile with `AWS_PROFILE` when needed.

### Disk Usage & Cleanup

Nix stores old versions of your profile so you can rollback. To free up space:
```bash
# Delete old generations
nix-collect-garbage -d
```

## 💡 Notes

* VS Code: Your settings.json is now read-only. To change a setting, edit vscode.nix and rebuild.
* Python/Java: This setup includes Python 3.12 tooling and JDK 21.
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
