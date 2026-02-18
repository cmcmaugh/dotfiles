# tmux Cheatsheet (This Config)

This cheatsheet matches `tmux.nix` in this repo.

## Basics

- Prefix key: `Ctrl+a` (not `Ctrl+b`)
- Send literal prefix (nested tmux): `Ctrl+a` then `Ctrl+a`
- Window numbering starts at `1`
- Pane numbering starts at `1`
- Mouse support is enabled
- System clipboard integration is enabled

## Session and Config

- Reload tmux config: `Prefix` + `r`
- Toggle "keys off" mode for nested sessions: `F12`
- Restore normal keys after toggle: `F12` again

Notes:
- In keys-off mode, prefix is disabled (`prefix None`) and tmux key-table is set to `off`.
- Status line shows `OFF` when keys-off mode is active.

## Pane Management

- Split left/right: `Prefix` + `|`
- Split up/down: `Prefix` + `-`
- Move pane focus left: `Ctrl+h`
- Move pane focus down: `Ctrl+j`
- Move pane focus up: `Ctrl+k`
- Move pane focus right: `Ctrl+l`
- Move to last pane: `Ctrl+\`

Notes:
- `Prefix` + `"` and `Prefix` + `%` are unbound.
- `Ctrl+h/j/k/l` are smart: when inside Vim/Neovim/FZF they are sent to the app; otherwise tmux changes pane.

## Window Management

- Previous window: `Ctrl+Left` (no prefix)
- Next window: `Ctrl+Right` (no prefix)
- Jump to window `N`: `Prefix` + `N` (for `1..9`, default tmux behavior)
- Rename window: `Prefix` + `,` (default tmux behavior)
- New window: `Prefix` + `c` (default tmux behavior)
- Kill current window: `Prefix` + `&` (default tmux behavior)

Swap/move windows (command prompt):

1. Open command prompt: `Prefix` + `:`
2. Use one of:
   - Swap current window with left neighbor: `swap-window -t -1`
   - Swap current window with right neighbor: `swap-window -t +1`
   - Move current window to index 3: `move-window -t 3`

## Copy Mode (Vi)

- Enter copy mode: `Prefix` + `[` (default tmux behavior)
- Begin selection: `v`
- Copy selection: `y`
- Exit copy mode: `q` or `Esc` (default tmux behavior)

## Remote Session Behavior

When `$SSH_CLIENT` is set, tmux loads `~/.config/tmux/tmux.remote.conf`:

- Status bar is moved to bottom
- Status-right is simplified for remote usage

## Plugins Enabled

- `battery`
- `online-status`
- `sidebar`
- `copycat`
- `open`
- `yank`
- `sysstat`
- `prefix-highlight`

Status line includes:
- Prefix indicator
- OFF indicator (when key table is off)
- Zoom indicator
- CPU / memory / load
- user@host
- date/time
- battery
- online status
