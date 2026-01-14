{ config, lib, pkgs, ... }:
let
  sshPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
in
{
  imports = [
    ./firefox.nix
    (import ./git.nix { inherit sshPath; })
  ];

  programs.home-manager.enable = true;
  news.display = "silent";
  home = {
    stateVersion = "24.05";  # DO NOT CHANGE

    username = "mika";
    homeDirectory = "/Users/mika";

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
      "Library/Application Support/Code - Insiders/User/settings.json".text = ''
        {
          "chat.disableAIFeatures": true,
          "editor.acceptSuggestionOnEnter": "off",
          "editor.formatOnPaste": true,
          "editor.formatOnSave": true,
          "editor.multiCursorModifier": "ctrlCmd",
          "editor.scrollBeyondLastLine": false,
          "files.defaultLanguage": "Markdown",
          "files.insertFinalNewline": true,
          "files.trimFinalNewlines": true,
          "files.trimTrailingWhitespace": true,
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
      location = "~/Pictures/Screenshots";
      show-thumbnail = false;
    };
  };
}
