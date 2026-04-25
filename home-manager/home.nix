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
      ffmpeg
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

          # prompt user for URLs
          urls="''${outdir}/$(date +%H-%M-%S)-urls.txt"
          vim "$urls"
          if [[ ! -s "$urls" ]]; then
              rm -f "$urls"
              echo "No URLs entered. Exiting."
              exit 0
          fi

          # attempt download using gallery-dl
          downloads=$(mktemp -d)
          failed_urls=$(mktemp)
          while read -r url; do
              if ! gallery-dl \
                  --directory "''${downloads}" \
                  --filename "{username|author[name]|author[handle]|blog[name]|author}-{id|tweet_id|post_id|media_id}-{num:>02}.{extension}" \
                  --cookies-from-browser firefox \
                  "$url"
              then
                  echo "$url" >> "''${failed_urls}"
              fi
          done < "$urls"

          # attempt download using yt-dlp
          if [[ -s "''${failed_urls}" ]]; then
              success_urls=$(mktemp)
              yt-dlp \
                  --paths "''${downloads}" \
                  --output "%(uploader)s-%(id)s.%(ext)s" \
                  --cookies-from-browser firefox \
                  --ignore-errors \
                  --print-to-file "after_video:%(webpage_url)s" "''${success_urls}" \
                  --batch-file "''${failed_urls}"
              remaining=$(grep -vxFf "''${success_urls}" "''${failed_urls}" || true)
              if [[ -n "$remaining" ]]; then
                  echo "$remaining" > "''${outdir}/failed.txt"
              fi
              rm "''${success_urls}"
          fi
          rm "''${failed_urls}"

          # normalize videos' format
          for f in "''${downloads}"/*; do
              mime=$(file --mime-type -b "$f")
              if [[ "$mime" == video/* ]]; then
                  filename=$(basename "$f")
                  name="''${filename%.*}"
                  ffmpeg -loglevel error -i "$f" -c:v libx265 -crf 18 -pix_fmt yuv420p -tag:v hvc1 -c:a aac "''${outdir}/''${name}.mp4"
              elif [[ "$mime" == image/* ]]; then
                  cp "$f" "''${outdir}/$(basename "$f")"
              fi
          done
          rm "$urls"
        '';
      })

      (writeShellApplication {
        name = "discordify";
        text = ''
          target_mb=9

          input="$1"
          dir=$(dirname "$input")
          filename=$(basename "$input")
          name="''${filename%.*}"

          # https://trac.ffmpeg.org/wiki/FFprobeTips#Formatcontainerduration
          duration=$(ffprobe -i "$input" -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 | cut -d. -f1)

          # https://trac.ffmpeg.org/wiki/Encode/H.265#Two-PassEncoding
          audio_kbitrate=128
          bitrate=$(( (target_mb * 8388) / duration - audio_kbitrate ))
          ffmpeg -y -i "$input" -c:v libx265 -b:v "''${bitrate}k" -x265-params pass=1 -an -f null /dev/null
          ffmpeg -y -i "$input" -c:v libx265 -b:v "''${bitrate}k" -x265-params pass=2 -pix_fmt yuv420p -tag:v hvc1 -c:a aac -b:a "''${audio_kbitrate}k" "''${dir}/''${name}-compressed.mp4"
          rm -f x265_2pass.log x265_2pass.log.cutree
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
