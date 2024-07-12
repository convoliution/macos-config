{ config, lib, pkgs, ... }:
let 
  homeDirectory = "/Users/miliu";
  globalVenvDir = "${homeDirectory}/.venv";
  gitHubPublicSshPath = "${homeDirectory}/.ssh/github";
in
{
  programs.home-manager.enable = true;
  news.display = "silent";
  home = {
    stateVersion = "24.05";  # DO NOT CHANGE
    
    username = "miliu";
    homeDirectory = homeDirectory;
    
    packages = with pkgs; [
      jq
      yq

      python311

      gnumake
      wget

      nixpkgs-fmt

      # (writeShellScriptBin "banana" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    activation = {
      setUpGlobalPythonVenv = lib.hm.dag.entryAfter ["installPackages"] ''
        PATH="${config.home.path}/bin:$PATH"
        GLOBAL_VENV_DIR="${globalVenvDir}"
        
        rm -rf $GLOBAL_VENV_DIR
        run python -m venv $GLOBAL_VENV_DIR
        source $GLOBAL_VENV_DIR/bin/activate

        python -m pip install --upgrade pip
      '';
    };
  };

  # TODO
  # programs.firefox = {
  #   enable = true;
  # };
  
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
      key = "${gitHubPublicSshPath}.pub";
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
        identityFile = gitHubPublicSshPath;
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

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
  ];
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    keybindings = [
        {
            "key" = "ctrl+tab";
            "command" = "workbench.action.nextEditorInGroup";
        }
        {
            "key" = "ctrl+shift+tab";
            "command" = "workbench.action.previousEditorInGroup";
        }
    ];
    extensions = [
      pkgs.vscode-extensions.bbenoist.nix
    ];
    userSettings = {
      "editor.multiCursorModifier" = "ctrlCmd";
      "editor.formatOnPaste" = true;
      "editor.scrollBeyondLastLine" = false;
      "editor.acceptSuggestionOnEnter" = "off";
      "files.defaultLanguage" = "Markdown";
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
      "window.restoreWindows" = "none";
      "workbench.startupEditor" = "none";
      "workbench.activityBar.location" = "hidden";
    };
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    initExtraBeforeCompInit = ''
      bindkey \^U backward-kill-line
    '';
    initExtra = ''
      source ${globalVenvDir}/bin/activate
    '';
  };
}
