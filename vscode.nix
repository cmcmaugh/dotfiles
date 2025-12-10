{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # FIX: Everything must now be under "profiles.default"
    profiles.default = {

      # Extensions
      extensions = with pkgs.vscode-extensions; [
        # Python
        charliermarsh.ruff
        ms-python.python
        ms-python.debugpy
        ms-python.vscode-pylance
        ms-python.isort

        # Vim
        vscodevim.vim

        # AI
        github.copilot
        github.copilot-chat

        # Java
        redhat.java
        vscjava.vscode-java-pack
        vscjava.vscode-maven
        vscjava.vscode-gradle

        # Jupyter
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers

        # Web / Misc
        ms-vscode.live-server
      ];

      # User Settings
      userSettings = {
        # Python Configuration
        "[python]" = {
          "editor.formatOnSave" = true;
          "editor.codeActionsOnSave" = {
            "source.fixAll" = "explicit";
            "source.organizeImports" = "explicit";
          };
          "editor.defaultFormatter" = "charliermarsh.ruff";
        };
        "python.terminal.launchArgs" = [
          "-m"
          "IPython"
          "--no-autoindent"
        ];
        "mypy.runUsingActiveInterpreter" = true;
        "mypy.debugLogging" = true;
        "python.testing.pytestEnabled" = true;

        # Vim Configuration
        "vim.vimrc.enable" = false;
        "vim.leader" = ",";

        # Keep Insert Mode recursive (usually fine, but can be NonRecursive too)
        "vim.insertModeKeyBindings" = [
          {
            "before" = ["j" "k"];
            "after" = ["<Esc>"];
          }
        ];

        # FIX: Use "NonRecursive" to allow swapping keys without loops
        "vim.normalModeKeyBindingsNonRecursive" = [
          {
            "before" = [ ";" ];
            "after" = [ ":" ];
          }
          {
            "before" = [ ":" ];
            "after" = [ ";" ];
          }
        ];

        # FIX: Visual Mode NonRecursive
        "vim.visualModeKeyBindingsNonRecursive" = [
          {
            "before" = [ ";" ];
            "after" = [ ":" ];
          }
          {
            "before" = [ ":" ];
            "after" = [ ";" ];
          }
        ];

        # Java Configuration
        "java.imports.gradle.wrapper.checksums" = [
          {
            "sha256" = "1ca04e74ee966719e1155341da6fca086d0d21686db29e3efdebd03817e639e0";
            "allowed" = true;
          }
        ];

        # Explorer & Git Behavior
        "git.confirmSync" = false;
        "explorer.confirmDelete" = false;
        "explorer.fileNesting.patterns" = {
          "*.ts" = "\${capture}.js";
          "*.js" = "\${capture}.js.map, \${capture}.min.js, \${capture}.d.ts";
          "*.jsx" = "\${capture}.js";
          "*.tsx" = "\${capture}.ts";
          "tsconfig.json" = "tsconfig.*.json";
          "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb, bun.lock";
          "*.sqlite" = "\${capture}.\${extname}-*";
          "*.db" = "\${capture}.\${extname}-*";
        };

        # Visuals & Telemetry
        "window.zoomLevel" = 2;
        "window.restoreWindows" = "none";
        "terminal.integrated.fontFamily" = "'Hack Nerd Font Mono'";
        "redhat.telemetry.enabled" = false;
        "editor.formatOnType" = true;
      };
    };
  };
}
