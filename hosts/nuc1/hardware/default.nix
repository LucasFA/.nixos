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
}
