{ config, pkgs, ... }:
{
  #services.easyeffects.enable = true;
  home.packages = with pkgs; [
    # gnomeExtensions.easyeffects-preset-selector
  ];
  #lib.optional config.services.desktopManager.gnome.enable
  #gnomeExtensions.easyeffects-preset-selector;
}
