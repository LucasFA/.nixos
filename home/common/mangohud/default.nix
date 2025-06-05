{ config, pkgs, ... }:
{
  programs = {
    mangohud = {
      enable = false;
      enableSessionWide = false;
    };
  };
  home.file.mangohud = {
    source = ./MangoHud.conf;
    target = "${config.xdg.configHome}/MangoHud/MangoHud.conf";
  };
}
