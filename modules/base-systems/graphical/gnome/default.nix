{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./gnome-fix.nix
    ./keyring.nix
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

  users.users.lucasfa.packages = with pkgs; [
    gnome-tweaks
  ];
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
