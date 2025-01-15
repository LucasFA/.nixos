{ pkgs, ... }:

{
  imports = [
    ../graphical
  ];

  environment.systemPackages = with pkgs; [
    telegram-desktop
    element-desktop
    signal-desktop
    qbittorrent
    discord
  ];

  services = {
    flatpak.enable = true;
    tailscale.enable = true;
  };
  programs = {
    htop.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucasfa = {
    isNormalUser = true;
    description = "Lucas";
    extraGroups = [
      "networkmanager"
      "wheel"
    ] ++ 
      lib.optional config.virtualisation.docker.enable "docker";
  };

  services = {
    syncthing = {
      enable = true;
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
