{ pkgs, lib, ... }:
{
  imports = [ ./dconf.nix ];

  services.caffeine.enable = true;
  services.kdeconnect = {
    # enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
    indicator = true;
  };
}
