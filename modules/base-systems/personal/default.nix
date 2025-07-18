{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ../graphical
    ./torrent.nix
  ];

  environment.systemPackages = with pkgs; [
    spotify
    telegram-desktop
    element-desktop
    signal-desktop
    discord
    jellyfin-media-player
    rquickshare
    subsurface
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
      firefoxIntegration.enable = true; # Let Firefox use AutoFirma
    };
    configuradorfnmt = {
      enable = true;
      firefoxIntegration.enable = true;
    };
    firefox.policies.SecurityDevices = {
      "OpenSC PKCS#11" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
      "DNIeRemote" = "${config.programs.dnieremote.finalPackage}/lib/libdnieremotepkcs11.so";
    };
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
