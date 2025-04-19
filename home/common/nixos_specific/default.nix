{ config, pkgs, ... }:
{
  programs = {
    mangohud = {
      enable = true;
      enableSessionWide = false;
    };
  };
  home.file.mangohud = {
    source = ./MangoHud.conf;
    target = "${config.xdg.configHome}/MangoHud/MangoHud.conf";
  };
}
