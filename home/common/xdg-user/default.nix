{ config, ... }:
{
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;
  xdg.userDirs.music = "${config.home.homeDirectory}/xdg/Music";
  xdg.userDirs.desktop = "${config.home.homeDirectory}/xdg/Desktop";
  xdg.userDirs.pictures = "${config.home.homeDirectory}/xdg/Pictures";
  xdg.userDirs.publicShare = "${config.home.homeDirectory}/xdg/Public";
  xdg.userDirs.templates = "${config.home.homeDirectory}/xdg/Templates";
  xdg.userDirs.videos = "${config.home.homeDirectory}/xdg/Videos";
}
