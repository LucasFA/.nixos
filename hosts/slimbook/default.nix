{ config, lib, pkgs, ... }:

{
  fileSystems."/mnt/data" = 
    { device = "/dev/disk/by-uuid/0cf1fffe-2c1f-4c9a-b29b-5d63d22dd602";
      fsType = "ext4";
    };
  fileSystems."/home/games" = {
	device = "/mnt/data/games";
	options = [ "bind" ];
	};
}
