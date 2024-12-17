{ config, lib, pkgs, ... }:

{
  imports = [
    "${builtins.fetchGit { 
	url = "https://github.com/LucasFA/nixos-hardware.git"; 
	ref = "master";
	rev = "b0564f4a0cb20d89f3906d36ccc500c591d71922";
	}}/slimbook/hero/rpl_rtx"
    ./nvidia.nix
  ];
  fileSystems."/" = {
    options = [ "relatime" "lazytime"];
    depends = [ "/nix" ];
  };
  fileSystems."/nix" = {
     device = "/dev/disk/by-label/Nix";
     fsType = "btrfs";
     neededForBoot = true;
     options = [ "noatime" ];
};
  fileSystems."/mnt/data" = 
    { device = "/dev/disk/by-uuid/0cf1fffe-2c1f-4c9a-b29b-5d63d22dd602";
      fsType = "ext4";
      options = [ "nofail" "noatime" ];
    };
  fileSystems."/home/lucasfa/games" = {
	mountPoint = "/home/lucasfa/games";
	device = "/mnt/data/games";
	options = [ "bind" ];
	};
}
