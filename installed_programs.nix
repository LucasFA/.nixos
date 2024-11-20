{ config, pkgs, ... }:

{
  imports = [ ];

  services = {
	flatpak.enable = true;
	tailscale.enable = true;
  	syncthing = {
	  enable = true;
	  dataDir = "/home/lucasfa/syncthing/";
	  user = "lucasfa";
	  group = "users";
	  openDefaultPorts = true;
  	  guiAddress = "127.0.0.1:8384";
	  overrideDevices = false;
	  overrideFolders = false;
  };
};

  programs = {
	firefox.enable = true;
  	fish.enable = true;
  	htop.enable = true;
	steam.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    gparted
    ventoy-full
    tealdeer
    dconf
    wl-clipboard
    nvd
  #  wget
  ];
}
