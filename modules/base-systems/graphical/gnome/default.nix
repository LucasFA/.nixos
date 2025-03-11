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

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  users.users.lucasfa.packages = with pkgs; [
    gnome-tweaks
    # ffmpegthumbnailer # thumbnails without totem installed
  ];
  environment.systemPackages = with pkgs; [
    libgsf
  ];
  environment.gnome.excludePackages = (
    with pkgs;
    [
      gnome-photos
      gnome-tour
      gedit

      gnome-music
      epiphany # web browser
      # totem # video player and thumbnail generator
      geary # email reader
    ]
  );
}
