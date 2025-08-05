{
  config,
  pkgs,
  lib,
  ...
}:
{
  age.secrets = {
    "restic/htpasswd" = {
      file = ./../../secrets/restic/htpasswd.age;
      path = "/mnt/WD_8tb/backups/.htpasswd";
      owner = "restic";
      group = "restic";
    };
  };
  services.restic.server = {
    enable = true;
    htpasswd-file = config.age.secrets."restic/htpasswd".path;
    dataDir = "/mnt/WD_8tb/backups";
    listenAddress = "8000";
  };
}
