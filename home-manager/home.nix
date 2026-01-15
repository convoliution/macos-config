{ config, lib, pkgs, ... }:
let
  username = "mika";
  email = "hello@convoliution.com";
  sshPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
in
{
  imports = [
    ./firefox.nix
    (import ./git.nix { inherit sshPath email; })
  ];

  programs.home-manager.enable = true;
  news.display = "silent";
  home = {
    stateVersion = "24.05";  # DO NOT CHANGE

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
      "Library/Application Support/Code/User/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/vs-code/settings.json";
      "Library/Application Support/Code/User/keybindings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/vs-code/keybindings.json";
      "Library/Application Support/Code - Insiders/User/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/vs-code/settings.json";
      "Library/Application Support/Code - Insiders/User/keybindings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/vs-code/keybindings.json";
    };
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
