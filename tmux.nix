{ config, pkgs, ... }:

let
  # Define the content of your remote config here
  tmuxRemoteConf = ''
    # Show status bar at bottom for remote session to avoid stacking with local one
    set -g status-position bottom

    # In remote mode we don't show "clock" and "battery status" widgets
    set -g status-left "$wg_session"
    set -g status-right "#{prefix_highlight} $wg_is_keys_off $wg_is_zoomed #{sysstat_cpu} | #{sysstat_mem} | #{sysstat_loadavg} | $wg_user_host | #{online_status}"
  '';
in
{
  # 1. Write the remote config to ~/.config/tmux/tmux.remote.conf
  xdg.configFile."tmux/tmux.remote.conf".text = tmuxRemoteConf;

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    baseIndex = 1; # Replaces: set -g base-index 1
    escapeTime = 0; # Replaces: set -s escape-time 0
    historyLimit = 100000;

    # 2. Nix manages plugins (replaces TPM)
    plugins = with pkgs.tmuxPlugins; [
      battery
      online-status
      sidebar
      copycat
      open
      yank
      sysstat
      prefix-highlight
      # Note: 'vim-tmux-navigator' is usually managed in Vim,
      # but the bindings in extraConfig handle the tmux side.
    ];

    # 3. Your custom configuration
    extraConfig = ''
      # Better prefix
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      # Enable mouse support
      set -g mouse on
      set -g set-clipboard on

      # --- Smart pane switching with awareness of Vim splits ---
      # (Note: ''${} is how we escape $ in Nix multi-line strings)
      vim_pattern='(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +''${vim_pattern}$'"

      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'

      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l

      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # Easy window switching
      bind -n C-Left  previous-window
      bind -n C-Right next-window

      # Reload tmux config easily
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # Status bar settings
      set -g status-bg black
      set -g status-fg white
      set -g status-left-length 20
      set -g status-right-length 150
      set -g status-interval 5
      set -g status-left '#[fg=green]#S'
      set -g status-right '#[fg=cyan]%Y-%m-%d %H:%M#[default]'

      # Vi-style copy mode
      setw -g mode-keys vi
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection

      # (Note: base-index is handled by Nix options above)
      setw -g pane-base-index 1

      # =====================================
      # ===           Theme               ===
      # =====================================
      color_orange="colour166"
      color_purple="colour134"
      color_green="colour076"
      color_blue="colour39"
      color_yellow="colour220"
      color_red="colour160"
      color_black="colour232"
      color_white="white"

      color_dark="$color_black"
      color_light="$color_white"
      color_session_text="$color_blue"
      color_status_text="colour245"
      color_main="$color_orange"
      color_secondary="$color_purple"
      color_level_ok="$color_green"
      color_level_warn="$color_yellow"
      color_level_stress="$color_red"
      color_window_off_indicator="colour088"
      color_window_off_status_bg="colour238"
      color_window_off_status_current_bg="colour254"

      # =====================================
      # ===    Appearence and status bar  ===
      # =====================================
      set -g mode-style "fg=default,bg=$color_main"
      set -g message-style "fg=$color_main,bg=$color_dark"
      set -g status-style "fg=$color_status_text,bg=$color_dark"
      set -g window-status-separator ""
      separator_powerline_left=""
      separator_powerline_right=""

      setw -g window-status-format " #I:#W "
      setw -g window-status-current-style "fg=$color_light,bold,bg=$color_main"
      setw -g window-status-current-format "#[fg=$color_dark,bg=$color_main]$separator_powerline_right#[default] #I:#W# #[fg=$color_main,bg=$color_dark]$separator_powerline_right#[default]"
      setw -g window-status-activity-style "fg=$color_main"
      setw -g pane-active-border-style "fg=$color_main"

      set -g status on
      set -g status-position top
      set -g status-justify left
      set -g status-right-length 100

      wg_session="#[fg=$color_session_text] #S #[default]"
      wg_battery="#{battery_status_fg} #{battery_icon} #{battery_percentage}"
      wg_date="#[fg=$color_secondary]%h %d %H:%M#[default]"
      wg_user_host="#[fg=$color_secondary]#(whoami)#[default]@#H"
      wg_is_zoomed="#[fg=$color_dark,bg=$color_secondary]#{?window_zoomed_flag,[Z],}#[default]"
      wg_is_keys_off="#[fg=$color_light,bg=$color_window_off_indicator]#([ $(tmux show-option -qv key-table) = 'off' ] && echo 'OFF')#[default]"

      set -g status-left "$wg_session"
      set -g status-right "#{prefix_highlight} $wg_is_keys_off $wg_is_zoomed #{sysstat_cpu} | #{sysstat_mem} | #{sysstat_loadavg} | $wg_user_host | $wg_date $wg_battery #{online_status}"

      # Plugin config
      set -g @online_icon "#[fg=$color_level_ok]●#[default]"
      set -g @offline_icon "#[fg=$color_level_stress]●#[default]"
      set -g @sysstat_mem_view_tmpl 'MEM:#[fg=#{mem.color}]#{mem.pused}#[default] #{mem.used}'

      set -g @sysstat_cpu_color_low "$color_level_ok"
      set -g @sysstat_cpu_color_medium "$color_level_warn"
      set -g @sysstat_cpu_color_stress "$color_level_stress"
      set -g @sysstat_mem_color_low "$color_level_ok"
      set -g @sysstat_mem_color_medium "$color_level_warn"
      set -g @sysstat_mem_color_stress "$color_level_stress"
      set -g @sysstat_swap_color_low "$color_level_ok"
      set -g @sysstat_swap_color_medium "$color_level_warn"
      set -g @sysstat_swap_color_stress "$color_level_stress"

      set -g @batt_color_full_charge "#[fg=$color_level_ok]"
      set -g @batt_color_high_charge "#[fg=$color_level_ok]"
      set -g @batt_color_medium_charge "#[fg=$color_level_warn]"
      set -g @batt_color_low_charge "#[fg=$color_level_stress]"

      set -g @prefix_highlight_output_prefix '['
      set -g @prefix_highlight_output_suffix ']'
      set -g @prefix_highlight_fg "$color_dark"
      set -g @prefix_highlight_bg "$color_secondary"
      set -g @prefix_highlight_show_copy_mode 'on'
      set -g @prefix_highlight_copy_mode_attr "fg=$color_dark,bg=$color_secondary"

      set -g @sidebar-tree 't'
      set -g @sidebar-tree-focus 'T'
      set -g @sidebar-tree-command 'tree -C'
      set -g @open-S 'https://www.google.com/search?q='

      # ==============================================
      # ===   Nesting local and remote sessions     ===
      # ==============================================
      # Session is considered to be remote when we ssh into host
      if-shell 'test -n "$SSH_CLIENT"' \
          'source-file ~/.config/tmux/tmux.remote.conf'

      # Toggle key bindings (F12)
      bind -T root F12  \
          set prefix None \;\
          set key-table off \;\
          set status-style "fg=$color_status_text,bg=$color_window_off_status_bg" \;\
          set window-status-current-format "#[fg=$color_window_off_status_bg,bg=$color_window_off_status_current_bg]$separator_powerline_right#[default] #I:#W# #[fg=$color_window_off_status_current_bg,bg=$color_window_off_status_bg]$separator_powerline_right#[default]" \;\
          set window-status-current-style "fg=$color_dark,bold,bg=$color_window_off_status_current_bg" \;\
          if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
          refresh-client -S \;\

      bind -T off F12 \
        set -u prefix \;\
        set -u key-table \;\
        set -u status-style \;\
        set -u window-status-current-style \;\
        set -u window-status-current-format \;\
        refresh-client -S
    '';
  };
}
