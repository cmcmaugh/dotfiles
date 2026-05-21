{ config, pkgs, lib, ... }:

let
  blackPinned = pkgs.python313Packages.black.overrideAttrs (_: rec {
    version = "25.1.0";
    src = pkgs.fetchPypi {
      pname = "black";
      inherit version;
      hash = "sha256-M0ltXNEiKtczkTUrSujaFSU8Xeibk6gLPiyNmhnsJmY=";
    };
  });
in
{
  home.username = "conor";
  home.homeDirectory = "/home/conor";
  home.stateVersion = "25.05";

  imports = [
    ./vim.nix
    ./tmux.nix
  ];

  home.packages = with pkgs; [
    blackPinned
    gitFull
    curl
    uv
    rsync
    wget
    ripgrep
    tree
    xz
    fzf
    zsh
    zsh-powerlevel10k
    yq-go
  ];

  xdg.configFile."zsh/extra.zsh".source = ./zsh/extra.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
    };

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

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "common-aliases"
        "fzf"
        "python"
        "dirhistory"
        "sudo"
        "z"
      ];
    };

    initContent = ''
      source ${config.xdg.configHome}/zsh/extra.zsh
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
  };

  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ./bash/bashrc;
  };

  home.file = {
    ".p10k.zsh".source = ./zsh/.p10k.zsh;
    ".local/bin/tmux_autolaunch.sh" = {
      source = ./scripts/tmux_autolaunch.sh;
      executable = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "vim";
    PAGER = "less";
  };

  home.sessionPath = [
    "/opt/puppetlabs/bin"
    "${config.home.homeDirectory}/.npm-global/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;
}
