{ config, lib, pkgs, ... }:
let 
  homeDirectory = "/Users/mika";
  sshPath = "${homeDirectory}/.ssh/id_ed25519";
in
{
  programs.home-manager.enable = true;
  news.display = "silent";
  home = {
    stateVersion = "24.05";  # DO NOT CHANGE
    
    username = "mika";
    homeDirectory = homeDirectory;
    
    packages = with pkgs; [
      jq
      yq

      uv

      gnumake
      wget

      nixpkgs-fmt
    ];

    file = {
      ".mypy.ini".text = ''
        [mypy]
        plugins = pydantic.mypy
      '';
      "Library/Application Support/Code - Insiders/User/settings.json".text = ''
        {
          "editor.acceptSuggestionOnEnter": "off",
          "editor.formatOnPaste": true,
          "editor.formatOnSave": true,
          "editor.multiCursorModifier": "ctrlCmd",
          "editor.scrollBeyondLastLine": false,
          "files.defaultLanguage": "Markdown",
          "files.insertFinalNewline": true,
          "files.trimFinalNewlines": true,
          "git.openRepositoryInParentFolders": "always",
          "window.restoreWindows": "none",
          "workbench.activityBar.location": "hidden",
          "workbench.editor.focusRecentEditorAfterClose": false,
          "workbench.startupEditor": "none",

          "[python]": {
            "editor.defaultFormatter": "charliermarsh.ruff"
          },
          "mypy.runUsingActiveInterpreter": true,
          "ruff.importStrategy": "fromEnvironment"
        }
      '';
      "Library/Application Support/Code - Insiders/User/keybindings.json".text = ''
        [
          {
            "key": "ctrl+tab",
            "command": "workbench.action.nextEditorInGroup"
          },
          {
            "key": "ctrl+shift+tab",
            "command": "workbench.action.previousEditorInGroup"
          }
        ]
      '';
    };
  };
  
  programs.git = {
    enable = true;
    aliases = {
      alog = "log --graph --all --format=format:'%C(bold yellow)%h%C(reset) - %C(bold blue)%ar%C(reset)%C(auto)%d%C(reset)%n%w(72,10,10)%C(white)%s%C(reset)%n%C(dim white)%an%C(reset)'";
      afet = "fetch --all --prune";
      acom = "commit --amend --no-edit";
      ares = "reset --hard HEAD";
    };
    userEmail = "miliu@protonmail.com";
    userName = "Michael Liu";
    signing = {
      key = "${sshPath}.pub";
      signByDefault = true;
    };
    extraConfig = {
      gpg.format = "ssh";
      init.defaultBranch = "main";
      push.default = "current";
    };
    ignores = [
      # Compiled source
      "*.com"
      "*.class"
      "*.dll"
      "*.exe"
      "*.o"
      "*.pyc"
      "*.so"

      # Packages
      "*.7z"
      "*.dmg"
      "*.gz"
      "*.iso"
      "*.jar"
      "*.rar"
      "*.tar"
      "*.zip"

      # Logs and databases
      "*.log"
      "*.sql"
      "*.sqlite"

      # Caches
      ".sass-cache"
      "__pycache__"

      # OS generated files
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"

      # Jupyter Notebook checkpoints
      ".ipynb_checkpoints"
    ];
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "GitHub" = {
        host = "github.com";
        identityFile = sshPath;
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
        };
      };
    };
  };

  programs.tmux = {
    enable = true;
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      syntax on
      set ruler
    '';
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    initExtraBeforeCompInit = ''
      bindkey \^U backward-kill-line
    '';
    shellAliases = {
      code = "code-insiders";
      python3 = "python";
    };
  };
}
