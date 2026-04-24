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
      # data processing
      jq
      yq
      wget

      # development
      gnumake
      nixpkgs-fmt

      # package managers
      uv

      # media
      ffmpeg-full
      gallery-dl
      yt-dlp

      (writeShellApplication {
        name = "home-manage";
        text = ''
          nix flake update --flake path:"$HOME"/.config/home-manager
          home-manager switch --flake path:"$HOME"/.config/home-manager
        '';
      })

      (writeShellApplication {
        name = "medial";
        text = ''
          outdir=$(date +%Y-%m-%d)
          mkdir -p "$outdir"

          urls="''${outdir}/$(date +%H-%M-%S)-urls.txt"
          vim "$urls"
          if [[ ! -s "$urls" ]]; then
              rm -f "$urls"
              echo "No URLs entered. Exiting."
              exit 0
          fi

          downloads=$(mktemp -d)
          gallery-dl \
              -D "''${downloads}" \
              -f "{username}-{media_id}.{extension}" \
              --cookies-from-browser firefox \
              --input-file "$urls"
          for f in "''${downloads}"/*; do
              mime=$(file --mime-type -b "$f")
              if [[ "$mime" == video/* ]]; then
                  basename_f=$(basename "$f")
                  name="''${basename_f%.*}"
                  ffmpeg -i "$f" -vcodec libx264 -pix_fmt yuv420p -an "''${outdir}/''${name}.mp4"
              elif [[ "$mime" == image/* ]]; then
                  cp "$f" "''${outdir}/$(basename "$f")"
              fi
          done
          rm "$urls"
        '';
      })
    ];

    file = {
      ".mypy.ini".text = ''
        [mypy]
        plugins = pydantic.mypy
      '';

      "Library/Application Support/Code/User/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/app-configs/vs-code/settings.json";
      "Library/Application Support/Code/User/keybindings.json".source = ./app-configs/vs-code/keybindings.json;
      "Library/Application Support/Code - Insiders/User/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/app-configs/vs-code/settings.json";
      "Library/Application Support/Code - Insiders/User/keybindings.json".source = ./app-configs/vs-code/keybindings.json;

      "Library/Application Support/Firefox/installs.ini".source = ./app-configs/firefox/installs.ini;
      "Library/Application Support/Firefox/profiles.ini".source = ./app-configs/firefox/profiles.ini;
      "Library/Application Support/Firefox/Profiles/default/user.js".source = ./app-configs/firefox/user.js;
      "Library/Application Support/Firefox/Profiles/nightly/user.js".source = ./app-configs/firefox/user.js;
    };
  };

  launchd.agents.ssh-load-keychain = {
    enable = true;
    config = {
      ProgramArguments = [ "/usr/bin/ssh-add" "--apple-load-keychain" ];
      RunAtLoad = true;
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
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
        };
      };
      "GitHub" = {
        host = "github.com";
        identityFile = sshPath;
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
    initContent = lib.mkOrder 550 ''
      bindkey \^U backward-kill-line
    '';
    shellAliases = {
      python3 = "python";
    };
  };
}
