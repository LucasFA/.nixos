{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.lfa.roles.server;
  mountOpts = [
    "nofail"
    # "errors=remount-ro"
    "lazytime"
    "x-systemd.device-timeout=30s"
    "x-systemd.before=docker.service"
  ];
in
{
  config = lib.mkIf (cfg.enable && cfg.disk_pool.enable) {

    ########## mergerfs ##########

    environment.systemPackages = [ pkgs.mergerfs ];
    fileSystems = {
      "/mnt/disk_1" = {
        device = "/dev/disk/by-uuid/5db4981f-c258-484c-b185-44fac054c69d";
        fsType = "xfs";
        options = mountOpts;
      };
      "/mnt/parity_1" = {
        device = "/dev/disk/by-uuid/0df75437-661e-44d8-b695-f3c4ceda37c2";
        fsType = "xfs";
        options = mountOpts;
      };

      #/mnt/disk_* /mnt/pool fuse.mergerfs defaults,category.create=pfrd,func.getattr=newest,minfreespace=20G,fsname=mergerfs 0 0
      #/mnt/hdd0:/mnt/hdd1 /media mergerfs cache.files=off,category.create=pfrd,func.getattr=newest,dropcacheonclose=false 0 0
      "/mnt/pool" = {
        mountPoint = "/mnt/pool";
        fsType = "mergerfs";
        noCheck = true;
        device = "/mnt/disk_*";
        options = [
          "lazytime"
          "cache.files=off,category.create=pfrd,func.getattr=newest,dropcacheonclose=false"
          "minfreespace=50G"
        ];
      };
    };

    ########## snapraid ##########
    services.snapraid = {
      enable = true;
      dataDisks = {
        d1 = "/mnt/disk_1";
      };
      parityFiles = [ "/mnt/parity_1/snapraid.parity" ];
      contentFiles = [
        "/var/snapraid.content"
        "/mnt/disk_1/snapraid.content"
        "/mnt/parity_1/snapraid.content"
      ];
      exclude = [
        "/lost+found/"
        ".Trash-*/"
        ".recycle/"
      ];
      extraConfig = "
autosave 250
temp_limit 48
temp_sleep 10
";

      scrub.olderThan = 30; # days
    };
  };
}
