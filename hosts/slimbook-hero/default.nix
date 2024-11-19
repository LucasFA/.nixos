{ config, lib, pkgs, ... }:

{
  imports = [
    "${builtins.fetchGit { 
	url = "https://github.com/LucasFA/nixos-hardware.git"; 
	ref = "master";
	rev = "3cf99022bdcca6f7a7f7aef0672f9d8d8f5975e3";
	}}/slimbook/hero/rpl_rtx"
    ./nvidia.nix
  ];
  fileSystems."/mnt/data" = 
    { device = "/dev/disk/by-uuid/0cf1fffe-2c1f-4c9a-b29b-5d63d22dd602";
      fsType = "ext4";
    };
  fileSystems."/home/games" = {
	device = "/mnt/data/games";
	options = [ "bind" ];
	};
}
