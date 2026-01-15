{ config, lib, pkgs, ... }:
{
  home.file = {
    "Library/Application Support/Firefox/installs.ini".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/installs.ini";
    "Library/Application Support/Firefox/profiles.ini".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/profiles.ini";

    "Library/Application Support/Firefox/Profiles/default/user.js".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/user.js";
    "Library/Application Support/Firefox/Profiles/nightly/user.js".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/user.js";
  };
}
