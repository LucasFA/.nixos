{ config, pkgs, ... }:
{
  #services.easyeffects.enable = true;
  home.packages = with pkgs; [
    #gnomeExtensions.easyeffects-preset-selector
  ];
}
