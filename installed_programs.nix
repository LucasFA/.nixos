{ config, pkgs, ... }:

{
  imports = [ ];

  services = {
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
  };
}
