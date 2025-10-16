{ config, pkgs, ... }:


{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "conor";
  home.homeDirectory = "/home/conor";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.




  # Imports
  imports = [ ./vim.nix ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # Core tools
    git
    curl
    ripgrep
    xsel
    tree

    fzf
    tmux
    zsh
    zsh-powerlevel10k


  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Port your aliases from .zshrc
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      # alias for dotfiles management
      config = "/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
    };

    # History settings from .zshrc
    history = {
      size = 999999;
      path = "$HOME/.zsh_history";
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # Oh My Zsh integration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "common-aliases"
        "fzf"
        "tmux"
        "python"
        "dirhistory"
        "sudo"
        "z"
      ];
      # Set the theme. The p10k module handles the rest.
      # theme = "powerlevel10k/powerlevel10k";
    };

    # Anything else from .zshrc goes here
    initExtra = ''
      source ~/.p10k.zsh

      # For sourcing your tmux auto-launcher
      if [ -f "$HOME/dotfiles/scripts/tmux_autolaunch.sh" ]; then
          source "$HOME/dotfiles/scripts/tmux_autolaunch.sh"
      fi

      ec2connect() {
        local name=$1
        local host
        host=$(ec2-host "$name") || return 1
        tmux new-window -n "$name" "ssh conor@$host"
      }
    '';
  };

 # MISSING zshrc stuff:
#########################################################################################
#     if [ -f "$HOME/.path_extra" ]; then
#    source "$HOME/.path_extra"
#     fi
#
#   SAVEHIST=999999
#   setopt appendhistory nomenucomplete notify
#   setopt extended_history
#   setopt hist_expire_dups_first
#   setopt hist_ignore_all_dups
#   setopt hist_find_no_dups
#   setopt hist_save_no_dups
#
#some virtualenv shortcuts:
#    mkve2() { virtualenv -p python2.7 $HOME/venv/"$1"; }
#    mkve310() { virtualenv -p python3.10 $HOME/venv/"$1"; }
#    mkve38() { virtualenv -p python3.8 $HOME/venv/"$1"; }
#    mkve312() { virtualenv -p python3.12 $HOME/venv/"$1"; }
#    rmve() { rm -r $HOME/venv/"$1"; }
#
# 'workon' is handled by the 'python' oh-my-zsh plugin which sources virtualenvwrapper

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';j

    ".bashrc".source = ./bash/.bashrc;
    ".p10k.zsh".source = ./zsh/.p10k.zsh;
    ".tmux.conf".source = ./tmux/.tmux.conf;
    ".tmux/tmux.remote.conf".source = ./tmux/.tmux/tmux.remote.conf;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/conor/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
