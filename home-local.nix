{ config, pkgs, ... }:

let
  proxyPath = "${config.xdg.configHome}/ssh/ssm-ssh-proxy.sh";
  spotifyPlayerPackage = pkgs.spotify-player.overrideAttrs (old: {
    buildFeatures =
      builtins.filter (feature: feature != "rodio-backend") (old.buildFeatures or [ ])
      ++ [ "pulseaudio-backend" ];
    cargoBuildFeatures =
      builtins.filter (feature: feature != "rodio-backend") (old.cargoBuildFeatures or [ ])
      ++ [ "pulseaudio-backend" ];
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.libpulseaudio ];
  });
in
{
  imports = [
    ./home-common.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    xsel
    playerctl
    nerd-fonts.hack
    alacritty
    opentofu
    packer
    awscli2
    ssm-session-manager-plugin
    nodejs_20
    taskjuggler
    nixfmt
    jdk21
    ruff
    mypy
    (python312.withPackages (ps: with ps; [
      ipython
      tox
      cryptography
    ]))
    (writeShellScriptBin "toxu" ''
      export PATH=/usr/bin:/bin:$PATH
      exec tox "$@"
    '')
  ];

  programs.zsh.shellAliases = {
    tf12 = "terraform-1.2.7";
    terraform = "tofu";
  };

  xdg.configFile."ssh/ssm-ssh-proxy.sh" = {
    source = pkgs.replaceVars ./ssh/ssm-ssh-proxy.sh {
      aws = "${pkgs.awscli2}/bin";
      plugin = "${pkgs.ssm-session-manager-plugin}/bin";
    };
    executable = true;
  };

  programs.ssh.matchBlocks."*.aws" = {
    user = "conor";
    identitiesOnly = true;
    identityFile = "${config.home.homeDirectory}/.ssh/id_rsa";
    serverAliveInterval = 30;
    serverAliveCountMax = 3;
    proxyCommand = "${proxyPath} %h %p";
  };

  programs."spotify-player" = {
    enable = true;
    package = spotifyPlayerPackage;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 9;

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

  fonts.fontconfig.enable = true;
}
