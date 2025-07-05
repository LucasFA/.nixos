{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ../graphical
  ];

  environment.systemPackages = with pkgs; [
    spotify
    telegram-desktop
    element-desktop
    signal-desktop
    discord
    jellyfin-media-player
    rquickshare
  ];

  services = {
    flatpak.enable = true;
    tailscale.enable = true;
  };
  programs = {
    htop.enable = true;
    kdeconnect.enable = true;
    autofirma = {
      enable = true;
      # firefoxIntegration.enable = true;  # Let Firefox use AutoFirma
    };
    # configuradorfnmt.enable = true;
  };

  services = {
    syncthing = {
      enable = false;
      dataDir = "/home/lucasfa/syncthing/";
      user = "lucasfa";
      group = "users";
      openDefaultPorts = true;
      guiAddress = "127.0.0.1:8384";
      overrideDevices = false; # These
      overrideFolders = false; # two settings permit imperative folder declaration
    };
  };
}
