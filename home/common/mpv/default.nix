{ config, pkgs, ... }:
{
  home.file.mpv = {
    source = ./mpv.conf;
    target = "${config.xdg.configHome}/mpv/mpv.conf";
  };

  programs = {
    mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        mpv-cheatsheet # Show some simple mappings on '?'
        uosc # Nicer UI
        thumbfast
      ];
    };
  };
}
