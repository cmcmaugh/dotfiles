# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# To customize Powerlevel10k, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=999999
SAVEHIST=999999
setopt appendhistory nomenucomplete notify
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_save_no_dups
setopt share_history # share history between sessions

# Standard plugins can be found in ~/.oh-my-zsh/plugins/
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(git web-search tmux)
plugins=(
  git
  common-aliases
  fzf
  tmux
  python
  dirhistory
  sudo
  z
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# .dotifles config mangement
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#some virtualenv shortcuts:
mkve2() { virtualenv -p python2.7 $HOME/venv/"$1"; }
mkve310() { virtualenv -p python3.10 $HOME/venv/"$1"; }
mkve38() { virtualenv -p python3.8 $HOME/venv/"$1"; }
mkve312() { virtualenv -p python3.12 $HOME/venv/"$1"; }
rmve() { rm -r $HOME/venv/"$1"; }
# 'workon' is handled by the 'python' oh-my-zsh plugin which sources virtualenvwrapper

# FZF keybindings and fuzzy completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Auto-start or attach to tmux session on SSH login
if command -v tmux >/dev/null \
   && [ -z "$TMUX" ] \
   && [ -n "$SSH_CONNECTION" ] \
   && [ "$TERM" != "dumb" ]; then
  tmux attach-session -t default || tmux new-session -s default
fi
