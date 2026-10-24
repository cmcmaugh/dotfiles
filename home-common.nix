{
  config,
  pkgs,
  lib,
  ...
}:

let
  keyringsCodeartifact = pkgs.python3Packages.buildPythonPackage {
    pname = "keyrings-codeartifact";
    version = "2.1.2";
    pyproject = true;
    src = pkgs.fetchPypi {
      pname = "keyrings_codeartifact";
      version = "2.1.2";
      hash = "sha256-rHsAgoQCFu5URceGtbbFmaRVyzoNwC3UD9TVDQvKrC4=";
    };
    build-system = with pkgs.python3Packages; [ setuptools setuptools-scm wheel ];
    dependencies = with pkgs.python3Packages; [ keyring boto3 ];
    pythonImportsCheck = [ "keyrings.codeartifact" ];
  };
  keyringPython = pkgs.python3.withPackages (ps: [ ps.keyring keyringsCodeartifact ]);
  # Expose only keyring, without replacing the user's Python interpreter.
  codeartifactKeyring = pkgs.writeShellScriptBin "keyring" ''
    exec ${keyringPython}/bin/keyring "$@"
  '';
  blackPinned = pkgs.python313Packages.black.overrideAttrs (_: rec {
    version = "25.1.0";
    src = pkgs.fetchPypi {
      pname = "black";
      inherit version;
      hash = "sha256-M0ltXNEiKtczkTUrSujaFSU8Xeibk6gLPiyNmhnsJmY=";
    };
  });
  librarianPuppetGemHome = "${config.home.homeDirectory}/.local/share/gems";
in
{
  home.username = "conor";
  home.homeDirectory = "/home/conor";
  home.stateVersion = "25.05";

  imports = [
    ./vim.nix
    ./tmux.nix
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home.packages = with pkgs; [
    blackPinned
    codeartifactKeyring
    curl
    # Puppet 8 is used by slpuppet; 6.x supports Puppet 7 and 8.
    ruby
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

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user = {
        name = "Conor McMaugh";
        email = "conor@sensorlog.ie";
      };
      core = {
        editor = "vim";
        sshCommand = "ssh -F ~/.ssh/config";
      };
      diff.tool = "meld";
      difftool = {
        prompt = false;
        meld.cmd = ''meld "$LOCAL" "$REMOTE"'';
      };
    };
  };

  xdg.configFile."zsh/extra.zsh".source = ./zsh/extra.zsh;
  xdg.configFile."python_keyring/keyringrc.cfg".text = ''
    # Use the normal AWS credential chain, including AWS_PROFILE.
    [codeartifact]
  '';

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

  home.activation.fixSshConfigPermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -L "$HOME/.ssh/config" ]; then
      ssh_config_target="$(${pkgs.coreutils}/bin/readlink -f "$HOME/.ssh/config")"
      $DRY_RUN_CMD rm "$HOME/.ssh/config"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m 0600 "$ssh_config_target" "$HOME/.ssh/config"
    elif [ -f "$HOME/.ssh/config" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod 0600 "$HOME/.ssh/config"
    fi
  '';

  # nixpkgs does not package librarian-puppet. Install the Puppet 8 compatible
  # Ruby gem into the user's gem directory, without modifying system Ruby.
  home.activation.installLibrarianPuppet = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=${lib.makeBinPath [ pkgs.stdenv.cc pkgs.gnumake ]}:$PATH
    export GEM_HOME=${librarianPuppetGemHome}
    export GEM_PATH=${librarianPuppetGemHome}
    if ! ${pkgs.ruby}/bin/gem list --local --installed librarian-puppet --version 6.0.0 >/dev/null 2>&1; then
      $DRY_RUN_CMD ${pkgs.ruby}/bin/gem install --no-document --install-dir "$GEM_HOME" librarian-puppet --version 6.0.0
    fi
  '';

  home.sessionVariables = {
    EDITOR = "vim";
    GIT_SSH_COMMAND = "ssh -F ~/.ssh/config";
    PAGER = "less";
    UV_KEYRING_PROVIDER = "subprocess";
    UV_INDEX_CODEARTIFACT_SENSORLOG_USERNAME = "aws";
    GEM_HOME = librarianPuppetGemHome;
    GEM_PATH = librarianPuppetGemHome;
  };

  home.sessionPath = [
    "/opt/puppetlabs/bin"
    "${librarianPuppetGemHome}/bin"
    "${config.home.homeDirectory}/.npm-global/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;
}
