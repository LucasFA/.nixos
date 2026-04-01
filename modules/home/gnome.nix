{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./gnome/dconf.nix ];

  config = lib.mkIf config.lfa.home.gnome.enable {
    services.caffeine.enable = true;
    services.kdeconnect = {
      package = pkgs.gnomeExtensions.gsconnect;
      indicator = true;
    };

    home.packages = with pkgs; [
      # gnomeExtensions.hide-top-bar
    ];
  };
}
