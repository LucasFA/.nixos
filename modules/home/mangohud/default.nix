{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.lfa.home.mangohud.enable {
    programs = {
      mangohud = {
        enable = true;
        enableSessionWide = true;
      };
    };
    home.file.mangohud = {
      source = ./MangoHud.conf;
      target = "${config.xdg.configHome}/MangoHud/MangoHud.conf";
    };
  };
}
