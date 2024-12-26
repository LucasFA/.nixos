{ pkgs, ... }:
{
  home.packages = with pkgs; [
    signal-desktop
  ];
  services = {
    caffeine.enable = true;
  };
}
