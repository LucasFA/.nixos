{
  self,
  config,
  pkgs,
  lib,
  ...
}:
let
  backupsPath = "/mnt/pool/backups";
in
{
  age.secrets = {
    "restic/htpasswd" = {
      file = self.outPath + "/secrets/restic/htpasswd.age";
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
  # The pool is nofail, so local-fs.target doesn't wait for it
  systemd.services.restic-rest-server.unitConfig.RequiresMountsFor = [ backupsPath ];
}
