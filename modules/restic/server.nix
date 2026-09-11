{
  self,
  config,
  pkgs,
  lib,
  ...
}:
let backupsPath = "/mnt/pool/backups";
in
{
  age.secrets = {
    "restic/htpasswd" = {
      file = self.outPath + "/secrets/restic/htpasswd.age";
      path = backupsPath + ".htpasswd";
      owner = "restic";
      group = "restic";
    };
  };
  services.restic.server = {
    enable = true;
    privateRepos = true;
    htpasswd-file = config.age.secrets."restic/htpasswd".path;
    dataDir = backupsPath;
    listenAddress = "8000";
  };
}
