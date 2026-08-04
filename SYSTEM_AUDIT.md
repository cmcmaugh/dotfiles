# System Configuration Audit

Date: 2026-08-04

This machine is already mostly aligned with the intended split:

- APT owns Ubuntu, hardware integration, system services, and large desktop/system packages.
- Home Manager owns user tools, shells, editors, terminal configuration, and development tooling.
- Flatpak is not installed.
- Snap is installed and currently owns a small Ubuntu desktop/runtime set plus Firefox.

## Current Home Manager Coverage

Home Manager is active and has a current generation from 2026-07-08.

The repo currently manages:

- Shell startup: Bash, Zsh, Powerlevel10k.
- Terminal/editor tooling: tmux, Vim, Alacritty, VS Code settings and extensions.
- SSH client defaults plus the AWS SSM proxy helper.
- Git global config through `~/.config/git/config`.
- Core CLI/dev tools: Git, curl, uv, rsync, wget, ripgrep, fzf, yq, Node.js 20, Python 3.12 tooling, JDK 21, OpenTofu, AWS CLI, Packer, Codex.
- User-level Nix flakes config.
- `~/.gitconfig` was moved aside to `~/.gitconfig.hm-backup`.
- `~/.config/nix/nix.conf` was moved aside to `~/.config/nix/nix.conf.hm-backup` when Home Manager took ownership.

## Package Ownership Policy

Use this as the rule of thumb when adding or removing software.

### Keep In APT

APT should own packages that affect the base OS, kernel, drivers, desktop session, printing, virtualization, or system daemons.

Current APT packages that fit this category:

- `ubuntu-desktop-minimal`, `ubuntu-minimal`, `ubuntu-standard`
- `linux-generic-hwe-24.04`
- `build-essential`, `make`, `g++`, `pkg-config`, `cmake`
- `openssh-client`
- `cryptsetup`, `lvm2`, `efibootmgr`, `grub-efi-amd64`, `shim-signed`
- `virtualbox`
- `libreoffice`
- `google-chrome-stable`
- `pavucontrol`, `wl-clipboard` if Wayland clipboard integration is needed before Home Manager is applied
- `puppet-agent` if `/opt/puppetlabs/bin` and system integration are required

### Prefer Home Manager

Home Manager should own reproducible userland and development tools.

Moved or declared in this repo:

- Git config and `gitFull`
- User-level Nix flakes config
- `gh`
- `glow`
- `graphviz`
- `plantuml`
- `wl-clipboard`

Good future candidates to move from APT to Home Manager after testing:

- `dotnet-sdk-10.0`
- `nodejs` and `npm` if Ubuntu packages are no longer needed; Home Manager already provides `nodejs_20`
- `ghostwriter` if the Nix package or a Flatpak replacement works well

### Prefer Flatpak For GUI Apps

Flatpak is not installed right now. If you want a cleaner GUI-app boundary, install Flatpak and use it for apps whose config/state can remain outside this repo.

Likely Flatpak candidates:

- Obsidian, Slack, Discord, Spotify, VLC, GIMP, Inkscape, Zoom, qBittorrent, Remmina

Keep browser and virtualization choices in APT unless there is a clear reason to change them.

### Use Snap Only By Exception

Snap should be used only where it is the official or least-painful path.

Current snaps:

- `firefox`
- `snap-store`
- `firmware-updater`
- `desktop-security-center`
- `prompting-client`
- Runtime/base snaps: `bare`, `core24`, `gnome-46-2404`, `gtk-common-themes`, `mesa-2404`, `snapd`, `snapd-desktop-integration`

This is reasonable if you are happy with Ubuntu's default Firefox packaging. If you want to make Snap exceptions rarer, Firefox is the one real user-facing decision here.

## Unmanaged User Configuration

The following config exists under `~/.config` but is not obviously repo-managed. Most of it is application state and should not be blindly committed.

Candidates to review for declarative management:

- `~/.config/gh/config.yml`
- `~/.config/glow/glow.yml`
- `~/.config/gtk-3.0/bookmarks`
- `~/.config/mimeapps.list`
- `~/.config/pip/pip.conf`
- `~/.config/uv/uv.toml`
- `~/.config/wireshark/preferences`

Keep out of this public repo unless encrypted or sanitized:

- `~/.ssh`
- `~/.gnupg`
- `~/.aws`
- `~/.config/gh/hosts.yml`
- `~/.config/twg/auth.conf`
- `~/.config/sensorlog/agent.env`
- `~/.config/sl-m2m-client/*.pfx`
- browser profiles, cookies, app caches, logs, and generated state

## Follow-Up Cleanup

After applying Home Manager, check that these resolve to `~/.nix-profile/bin`:

```bash
which git gh glow dot plantuml wl-copy node npm
```

Then consider removing APT duplicates:

```bash
sudo apt remove gh glow graphviz plantuml nodejs npm
```

Do not remove `build-essential`, `g++`, `make`, `pkg-config`, or `cmake` unless you are sure no native builds depend on Ubuntu headers and tools.
