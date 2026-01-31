{ config, pkgs, ... }:
{
  services.easyeffects.enable = true;
  home.packages = with pkgs; [
    lib.optional
    config.services.desktopManager.gnome.enable
    gnomeExtensions.easyeffects-preset-selector
  ];
}
