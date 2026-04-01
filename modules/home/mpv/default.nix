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
          uosc # Nicer UI
          thumbfast
        ];
      };
    };
  };
}
