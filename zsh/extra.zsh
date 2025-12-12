# History & options
SAVEHIST=999999
setopt appendhistory nomenucomplete notify
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_find_no_dups
setopt hist_save_no_dups

# Optional extra PATH config
if [ -f "$HOME/.path_extra" ]; then
source "$HOME/.path_extra"
fi

# Powerlevel10k
source ~/.p10k.zsh

# tmux auto-launcher
if [ -f "$HOME/.local/bin/tmux_autolaunch.sh" ]; then
    source "$HOME/.local/bin/tmux_autolaunch.sh"
fi

# virtualenv helpers
mkve310()  { virtualenv -p python3.10 "$HOME/venv/$1"; }
mkve38()   { virtualenv -p python3.8  "$HOME/venv/$1"; }
mkve312()  { virtualenv -p python3.12 "$HOME/venv/$1"; }
rmve()     { rm -r "$HOME/venv/$1"; }

ec2connect() {
local name=$1
local host
host=$(ec2-host "$name") || return 1
tmux new-window -n "$name" "ssh conor@$host"
}