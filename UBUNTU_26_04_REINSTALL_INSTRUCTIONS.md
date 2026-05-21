# Ubuntu 26.04 Reinstall Instructions

Goal: clean Ubuntu 26.04 LTS install on the internal NVMe drive, LUKS encrypted, with a minimal base system and Nix Home Manager layered on top.

## Current Backup Location

External drive:

```text
/media/conor/ExternalDrive/reinstall-backup
```

Backup scripts:

```text
/home/conor/reinstall-backup.sh
/home/conor/projects-backup-excludes.txt
```

Run final backup before reinstall:

```bash
/home/conor/reinstall-backup.sh
```

Verify backup:

```bash
du -sh /run/media/conor/ExternalDrive/reinstall-backup
ls -la /run/media/conor/ExternalDrive/reinstall-backup
```

## Recommended Disk Layout

Internal disk:

```text
/dev/nvme0n1
  p1  1G      EFI System Partition   FAT32    /boot/efi
  p2  2G      boot                   ext4     /boot
  p3  rest    LUKS2 encrypted volume
      inside: ext4 root filesystem   ext4     /
      swap:   zram and/or swapfile
```

Use a single encrypted root filesystem. Do not create a separate `/home` partition unless there is a specific reason.

Avoid a dedicated LVM swap LV. Use zram plus an optional swapfile.

## Ubuntu Installer Choices

Boot the Ubuntu 26.04 LTS USB installer.

Recommended choices:

```text
Clean install
LUKS encryption enabled
Minimal/default app selection
Same username: conor
Filesystem: ext4
Skip ZFS
Skip TPM-backed encryption unless deliberately wanted
```

If the installer offers "Use LVM with encryption", that is acceptable. A plain LUKS passphrase is easiest to recover and move between systems.

## First Boot

Update the base system:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y openssh-client build-essential
```

`rsync` and `xz-utils` are part of the Ubuntu standard system.
Home Manager takes over `git`, `curl`, `vim`, and `tree` after the first `switch`.

## Install Desktop Apps

Install the remaining Ubuntu-managed desktop/system packages when ready:

```bash
sudo apt install -y virtualbox libreoffice
```

Optional swapfile if needed:

```bash
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## Install Nix

Install Nix daemon:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Reboot or log out and back in.

Enable flakes:

```bash
mkdir -p ~/.config/nix
printf "experimental-features = nix-command flakes\n" >> ~/.config/nix/nix.conf
```

## Restore Bootstrap Files

Restore dotfiles and secrets first:

```bash
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/dotfiles/ ~/dotfiles/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.ssh/ ~/.ssh/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.gnupg/ ~/.gnupg/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.gnupg-bak/ ~/.gnupg-bak/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.pki/ ~/.pki/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.aws/ ~/.aws/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.aws-default/ ~/.aws-default/
```

Fix permissions:

```bash
chmod 700 ~/.ssh ~/.gnupg
find ~/.ssh -type f -exec chmod 600 {} \;
find ~/.ssh -type d -exec chmod 700 {} \;
```

## Apply Home Manager

```bash
cd ~/dotfiles
nix flake show
nix run home-manager/master -- switch --flake .#conor
```

If the target name is different, use the target shown by `nix flake show`, for example:

```bash
nix run home-manager/master -- switch --flake .#conor@XPS-13-9300
```

## Restore User Data

After Home Manager works, restore data:

```bash
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/Documents/ ~/Documents/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/Pictures/ ~/Pictures/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/Media/ ~/Media/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/Dropbox/ ~/Dropbox/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/projects/ ~/projects/
```

Restore additional selected directories:

```bash
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/bin/ ~/bin/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/BGN_deployments/ ~/BGN_deployments/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/billing_reports/ ~/billing_reports/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/cfssl/ ~/cfssl/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/Desktop/ ~/Desktop/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/Downloads/ ~/Downloads/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/EK280_config/ ~/EK280_config/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/genealogy/ ~/genealogy/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/ism/ ~/ism/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/Key_Files/ ~/Key_Files/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/ROS/ ~/ROS/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/SensorlogOPC/ ~/SensorlogOPC/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/sensorlog_archive_automatic_signing_key/ ~/sensorlog_archive_automatic_signing_key/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/server_cert/ ~/server_cert/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/taskjuggler/ ~/taskjuggler/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/Videos/ ~/Videos/
```

Restore selected config/state:

```bash
    rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.config/ ~/.config/
    rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.local/ ~/.local/
    rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.gemini/ ~/.gemini/
    rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.ghcp-appmod/ ~/.ghcp-appmod/
    rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.VirtualBox/ ~/.VirtualBox/
    rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.gitconfig ~/.gitconfig
    rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.bash_history ~/.bash_history
    rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/.zsh_history ~/.zsh_history
```

Restore Codex essentials:

```bash
mkdir -p ~/.codex
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/config.toml ~/.codex/config.toml
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/auth.json ~/.codex/auth.json
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/rules/ ~/.codex/rules/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/memories/ ~/.codex/memories/
rsync -aHAX /run/media/conor/ExternalDrive/reinstall-backup/history.jsonl ~/.codex/history.jsonl
```

Enable Codex's Linux sandbox support:

```bash
printf '%s\n' \
  'kernel.unprivileged_userns_clone=1' \
  'kernel.apparmor_restrict_unprivileged_userns=0' \
| sudo tee /etc/sysctl.d/99-codex.conf >/dev/null

sudo sysctl --system
```

Disable Wi-Fi power saving in NetworkManager:

```bash
printf '%s\n' \
  '[connection]' \
  'wifi.powersave = 2' \
| sudo tee /etc/NetworkManager/conf.d/wifi-powersave-off.conf >/dev/null
```

Reboot after making both changes:

```bash
sudo reboot
```

## Restore VirtualBox VMs

Install VirtualBox:

```bash
sudo apt install -y virtualbox
```

Restore VMs:

```bash
rsync -aHAX "/run/media/conor/ExternalDrive/reinstall-backup/VirtualBox VMs/" ~/VirtualBox\ VMs/
```

Register each VM if needed:

```bash
VBoxManage registervm "$HOME/VirtualBox VMs/Windows7HomeClone Clone/Windows7HomeClone Clone.vbox"
VBoxManage registervm "$HOME/VirtualBox VMs/xp-opc2/xp-opc2.vbox"
```

## Post-Restore Checks

Check disk:

```bash
df -h
du -h --max-depth=1 ~ | sort -h | tail -n 20
```

Check Nix/Home Manager:

```bash
nix --version
home-manager --version
home-manager generations
```

Check SSH:

```bash
ssh -T git@github.com
```

Check VirtualBox:

```bash
VBoxManage list vms
```

## Notes

Do not restore the old home directory wholesale. Restore bootstrap files first, apply Home Manager, then restore user data.

Firefox profile is intentionally not restored because Firefox Sync is enabled against the personal account.

Rebuildable tool caches intentionally excluded:

```text
~/.cache
~/.npm
~/.gradle
~/.tox
~/.local/bin
~/.local/lib
~/.local/share/pnpm
~/.local/share/uv
snap
node_modules
.terraform provider caches
```
