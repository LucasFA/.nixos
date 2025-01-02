{
  config,
  lib,
  pkgs,
  ...
}:

{
  fileSystems."/" = {
    options = [
      "relatime"
      "lazytime"
    ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/884ae108-21f0-4683-ad71-a39ccd45e910";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "noatime" ];
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/nix" ];
    interval = "monthly";
  };
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/0cf1fffe-2c1f-4c9a-b29b-5d63d22dd602";
    fsType = "ext4";
    options = [
      "nofail"
      "noatime"
    ];
  };
  fileSystems."/home/lucasfa/games" = {
    mountPoint = "/home/lucasfa/games";
    device = "/mnt/data/games";
    options = [ "bind" "noatime" ];
  };
}
