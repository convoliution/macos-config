{ config, lib, pkgs, ... }:
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
  };
}
