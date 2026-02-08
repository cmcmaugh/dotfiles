{ config, pkgs, ... }:

let
 proxyPath = "${config.xdg.configHome}/ssh/ssm-ssh-proxy.sh";
in
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
  imports = [
    ./vim.nix
    ./tmux.nix
    ./vscode.nix
  ];

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
    gitFull
    curl
    wget
    ripgrep
    xsel
    tree

    fzf
    zsh
    zsh-powerlevel10k
    yq-go

    #graphical
    nerd-fonts.hack
    alacritty

    #AWS
    opentofu
    awscli2
    ssm-session-manager-plugin

    #programming languages
    nodejs_20

    #task juggler
    taskjuggler


    #vscode stuff
    nixfmt-rfc-style
    jdk17
    ruff
    mypy
    (python312.withPackages (ps: with ps; [
      ipython
    ]))

  ];

  xdg.configFile."zsh/extra.zsh".source = ./zsh/extra.zsh;

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

      tf12 = "terraform-1.2.7";
      terraform = "tofu";
      pk16 = "packer-1.6.1";

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
        "python"
        "dirhistory"
        "sudo"
        "z"
      ];
    };

    # 'workon' is handled by the 'python' oh-my-zsh plugin which sources virtualenvwrapper
    initContent = ''
      source ${config.xdg.configHome}/zsh/extra.zsh
    '';
  };


  xdg.configFile."ssh/ssm-ssh-proxy.sh" = {
    source = pkgs.replaceVars ./ssh/ssm-ssh-proxy.sh {
      aws = "${pkgs.awscli2}/bin";
      plugin = "${pkgs.ssm-session-manager-plugin}/bin";
    };
    executable = true;
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

    matchBlocks."*.aws" = {
      user = "conor";
      identitiesOnly = true;
      identityFile = "${config.home.homeDirectory}/.ssh/id_rsa";
      serverAliveInterval = 30;
      serverAliveCountMax = 3;

      # One-liner, no quoting hell
      proxyCommand = "${proxyPath} %h %p";
    };
  };



  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 12;

        normal = {
          family = "Hack Nerd Font Mono";
          style = "Medium";
        };

        bold = {
          family = "Hack Nerd Font Mono";
          style = "Heavy";
        };

        italic = {
          family = "Hack Nerd Font Mono";
          style = "Medium Italic";
        };

        bold_italic = {
          family = "Hack Nerd Font Mono";
          style = "Heavy Italic";
        };
      };
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
      };
    };
  };
  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ./bash/bashrc;
  };

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

    ".p10k.zsh".source = ./zsh/.p10k.zsh;
    ".local/bin/tmux_autolaunch.sh" = {
      source = ./scripts/tmux_autolaunch.sh;
      executable = true;
    };

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
    EDITOR = "vim";
    PAGER = "less";
    # EDITOR = "emacs";
  };
  home.sessionPath = [
    "/opt/puppetlabs/bin"
    "${config.home.homeDirectory}/.npm-global/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

  targets.genericLinux.enable = true;

  # Allows fontconfig to discover fonts installed by Home Manager
  fonts.fontconfig.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
