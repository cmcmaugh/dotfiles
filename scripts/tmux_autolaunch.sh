#!/bin/bash
# ~/dotfiles/scripts/tmux_autolaunch.sh

# This script is designed to be sourced by your shell's RC file (.bashrc, .zshrc)
# It automatically launches or attaches to a tmux session based on the environment.

# --- Configuration ---
# Session name for local terminals
LOCAL_TMUX_SESSION_NAME="local"
# Session name prefix for remote SSH terminals (will be suffixed with hostname and username)
REMOTE_TMUX_SESSION_PREFIX="ssh"
# --- End Configuration ---


# 1. Check if tmux is installed
# If tmux is not found, or if we're already inside a tmux session, do nothing.
command -v tmux &> /dev/null || return 0
[ -z "$TMUX" ] || return 0

# 2. Check if the current shell is interactive
# This prevents tmux from launching for non-interactive shells (e.g., scp, rsync, scripts).
case $- in *i*) ;; *) return 0;; esac

# 3. Determine if it's a remote SSH session or a local session
if [ -n "$SSH_TTY" ] || [ -n "$SSH_CLIENT" ]; then
    # It's an SSH session (remote)
    # Create a unique session name using hostname and current user for better organization
    # on different remote servers or when multiple users share an account.
    TMUX_SESSION_NAME="${REMOTE_TMUX_SESSION_PREFIX}-$(hostname)-$(whoami)"
else
    # It's a local session (laptop terminal)
    TMUX_SESSION_NAME="${LOCAL_TMUX_SESSION_NAME}"
fi

# 4. Attach to the session or create a new one
tmux attach-session -t "$TMUX_SESSION_NAME" || tmux new-session -s "$TMUX_SESSION_NAME"

# Optional: You can add more complex logic here, e.g., for specific projects,
# or to launch a different layout if a new session is created.