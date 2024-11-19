{ config, lib, pkgs, ... }:

{
  imports = [
    "${builtins.fetchGit { 
	url = "https://github.com/LucasFA/nixos-hardware.git"; 
	ref = "master";
	rev = "1d007a7c3992a260d4379e8e368a3f9305bcf4cd";
	}}/slimbook/hero_rpl_rtx"
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
