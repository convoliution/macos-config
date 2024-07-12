{ config, lib, pkgs, ... }:
let 
  homeDirectory = "/Users/miliu";
  globalVenvDir = "${homeDirectory}/.venv";
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
}
