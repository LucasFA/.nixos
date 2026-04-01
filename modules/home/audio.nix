{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #gnomeExtensions.easyeffects-preset-selector
  ];
}
