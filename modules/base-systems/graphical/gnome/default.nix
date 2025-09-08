{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./sleep-fix.nix
    ./fix-vid-properties.nix
    ./keyring.nix
  ];

  services = {
    displayManager.gdm = {
      enable = true;
      wayland = lib.mkDefault true;
    };
    desktopManager = {
      gnome.enable = true;
    };
  };

  programs.dconf.enable = true;
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  users.users.lucasfa.packages = with pkgs; [
    gnome-tweaks
    ffmpegthumbnailer # thumbnails without totem installed
  ];
  environment.systemPackages = with pkgs; [
    gnomeExtensions.gsconnect
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
