{ config, lib, pkgs, ... }:

{
  imports = [
    "${builtins.fetchGit { 
	url = "https://github.com/LucasFA/nixos-hardware.git"; 
	ref = "master";
	rev = "177d0bc2e759eca759ccaebc5bb73f5e96b09ab8";
	}}/slimbook/hero/rpl_rtx"
    ./nvidia.nix
  ];
  fileSystems."/mnt/data" = 
    { device = "/dev/disk/by-uuid/0cf1fffe-2c1f-4c9a-b29b-5d63d22dd602";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  fileSystems."/home/lucasfa/games" = {
	mountPoint = "/home/lucasfa/games";
	device = "/mnt/data/games";
	options = [ "bind" ];
	};
}
