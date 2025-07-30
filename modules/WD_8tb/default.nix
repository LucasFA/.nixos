{
  ...
}:

{
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [
      "/mnt/WD_8tb"
    ];
    interval = "monthly";
  };

  fileSystems."/mnt/WD_8tb" = {
    device = "/dev/disk/by-uuid/a265d817-d3d2-4658-ac5c-a925e94c3232";
    fsType = "btrfs";
    options = [
      "nofail"
      "lazytime"
      "x-systemd.device-timeout=15s"
      "autodefrag"
    ];
  };
  # fileSystems."/home/lucasfa/server/mounts" = {
  # mountPoint = "/home/lucasfa/server/mounts";
  # device = "/mnt/WD_8tb/server/config";
  # options = [
  # "bind"
  # ];
  # };
}
