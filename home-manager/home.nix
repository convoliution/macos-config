{ config, lib, pkgs, ... }:
let
  sshPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
in
{
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

  programs.git = {
    enable = true;
    aliases = {
      alog = "log --graph --all --format=format:'%C(bold yellow)%h%C(reset) - %C(bold blue)%ar%C(reset)%C(auto)%d%C(reset)%n%w(72,10,10)%C(white)%s%C(reset)%n%C(dim white)%an%C(reset)'";
    };
    userEmail = "miliu@protonmail.com";
    userName = "Michael Liu";
    signing = {
      key = "${sshPath}.pub";
      signByDefault = true;
    };
    extraConfig = {
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

  programs.firefox = {
    enable = true;
    package = null;
    profiles.default = {
      id = 0;
      settings = {
        # startup
        "browser.startup.homepage" = "about:blank";
        "browser.startup.page" = 3;  # restore previous session

        # blank new tabs
        "browser.newtabpage.enabled" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;

        # search
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        "browser.urlbar.placeholderName.private" = "DuckDuckGo";
        "browser.search.region" = "US";
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.bookmark" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.openpage" = false;
        "browser.urlbar.suggest.quickactions" = false;
        "browser.urlbar.suggest.quicksuggest.all" = false;
        "browser.urlbar.suggest.recentsearches" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.suggest.topsites" = false;

        # privacy
        "dom.security.https_only_mode" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "browser.contentblocking.category" = "strict";

        # DNS over HTTPS
        "network.trr.mode" = 3;  # always
        "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
        "doh-rollout.disable-heuristics" = true;

        # general behavior
        "browser.tabs.warnOnClose" = true;
        "browser.bookmarks.showMobileBookmarks" = false;
        "findbar.highlightAll" = true;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
        "sidebar.visibility" = "hide-sidebar";

        # developer tools
        "devtools.command-button-screenshot.enabled" = true;
        "devtools.application.enabled" = false;
        "devtools.memory.enabled" = false;
        "devtools.styleeditor.enabled" = false;

        # disable autofill
        "browser.formfill.enable" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # disable password manager
        "signon.rememberSignons" = false;

        # disable extension recommendations
        "browser.discovery.enabled" = false;

        # disable studies
        "app.shield.optoutstudies.enabled" = false;

        # disable AI
        "browser.tabs.groups.smart.userEnabled" = false;
        "browser.ml.chat.menu" = false;
        "browser.ml.linkPreview.enabled" = false;

        # crash reports
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = true;
      };
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
