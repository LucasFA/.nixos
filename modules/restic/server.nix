{
  pkgs,
  lib,
  ...
}:
{
  services.restic.server = {
    enable = true;
    # htpasswd-file = "";
    dataDir = "/mnt/WD_8tb/backups";
  };
}
