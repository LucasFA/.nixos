{
  pkgs,
  lib,
  ...
}:
let
  useGnome = true; # config.services.desktopManager.gnome.enable;
in
{
  imports = lib.optional useGnome ./dconf.nix;

  services.caffeine.enable = useGnome;
  services.kdeconnect = {
    # enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
    indicator = true;
  };

  home.packages = with pkgs; [
      gnomeExtensions.hide-top-bar
  ];
}
