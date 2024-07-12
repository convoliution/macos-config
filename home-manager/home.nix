{ config, lib, pkgs, ... }:
{
  programs.home-manager.enable = true;
  news.display = "silent";
  home = {
    stateVersion = "24.05";  # DO NOT CHANGE
    
    username = "miliu";
    homeDirectory = homeDirectory;
  };
}
