{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.lfa.home.work.enable {
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
    };
  };
}
