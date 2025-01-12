{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./gnome-fix.nix
  ];
  services.xserver = {
    displayManager.gdm = {
      enable = true;
      wayland = lib.mkDefault true;
    };
    desktopManager = {
      gnome.enable = true;
    };
  };

  environment.gnome.excludePackages = (
    with pkgs;
    [
      gnome-photos
      gnome-tour
      gedit

      gnome-music
      epiphany # web browser
      totem # video player
      geary # email reader
    ]
  );
}
