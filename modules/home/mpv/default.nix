{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.lfa.home.mpv.enable {
    home.file.mpv = {
      source = ./mpv.conf;
      target = "${config.xdg.configHome}/mpv/mpv.conf";
    };

    programs = {
      mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          mpv-cheatsheet-ng
          uosc # Nicer UI
          thumbfast
        ];
      };
    };
  };
}
