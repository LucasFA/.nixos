{ config, lib, pkgs, ... }:

{
  fileSystems."/" = {
    options = [ "relatime" "lazytime"];
  };
  fileSystems."/nix" = {
     device = "/dev/disk/by-label/Nix";
     fsType = "btrfs";
     neededForBoot = true;
     options = [ "noatime" ];
  };
  services.beesd.filesystems.nix_store = {
      spec = "LABEL=Nix";
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/nix/" ];
    interval = "1months";
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
