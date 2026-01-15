{ config, lib, pkgs, ... }:
let
  username = "mika";
  email = "hello@convoliution.com";
  sshPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
in
{
  programs.home-manager.enable = true;
  news.display = "silent";
  home = {
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.11"; # Please read the comment before changing.

    inherit username;
    homeDirectory = "/Users/${username}";

    sessionPath = [
      "$HOME/.local/bin"
    ];

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

      "Library/Application Support/Code/User/settings.json".source = ./app-configs/vs-code/settings.json;
      "Library/Application Support/Code/User/keybindings.json".source = ./app-configs/vs-code/keybindings.json;
      "Library/Application Support/Code - Insiders/User/settings.json".source = ./app-configs/vs-code/settings.json;
      "Library/Application Support/Code - Insiders/User/keybindings.json".source = ./app-configs/vs-code/keybindings.json;

      "Library/Application Support/Firefox/installs.ini".source = ./app-configs/firefox/installs.ini;
      "Library/Application Support/Firefox/profiles.ini".source = ./app-configs/firefox/profiles.ini;
      "Library/Application Support/Firefox/Profiles/default/user.js".source = ./app-configs/firefox/user.js;
      "Library/Application Support/Firefox/Profiles/nightly/user.js".source = ./app-configs/firefox/user.js;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      alias = {
        alog = "log --graph --all --format=format:'%C(bold yellow)%h%C(reset) - %C(bold blue)%ar%C(reset)%C(auto)%d%C(reset)%n%w(72,10,10)%C(white)%s%C(reset)%n%C(dim white)%an%C(reset)'";
      };
      user = {
        inherit email;
        name = "Michael Liu";
      };
      advice.detachedHead = "false";
      commit.verbose = "true";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = "true";
        renames = "copies";
      };
      fetch = {
        all = "true";
        prune = "true";
        pruneTags = "true";
      };
      gpg.format = "ssh";
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      pull.rebase = "true";
      push.autoSetupRemote = "true";
      rebase.updateRefs = "true";
      tag.sort = "version:refname";
    };
    signing = {
      key = "${sshPath}.pub";
      signByDefault = true;
    };
    ignores = [
      # compiled source
      "*.com"
      "*.class"
      "*.dll"
      "*.exe"
      "*.o"
      "*.pyc"
      "*.so"

      # packages
      "*.7z"
      "*.dmg"
      "*.gz"
      "*.iso"
      "*.jar"
      "*.rar"
      "*.tar"
      "*.zip"

      # logs and databases
      "*.log"
      "*.sql"
      "*.sqlite"

      # caches
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
    enableDefaultConfig = false;
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

  home.activation.createScreenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.home.homeDirectory}/Pictures/Screenshots
  '';
  targets.darwin.defaults = {
    "com.apple.screencapture" = {
      location = "${config.home.homeDirectory}/Pictures/Screenshots";
      show-thumbnail = false;
    };
  };
}
