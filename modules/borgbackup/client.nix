{
  pkgs,
  lib,
  ...
}:
let
  excludeList =
    [
      "*/cache2" # firefox
      "*/Cache"
      ".config/Code/CachedData"
      ".npm/_cacache"
      "*/node_modules"
      "*.pyc"
      "/home/lucasfa/dev/***/[.]git"
      "/home/lucasfa/games"
      "/home/*/.direnv"
      "/home/*/.cache"
      "/home/*/.cargo"
      "/home/*/.npm"
      "/home/*/.mozilla/firefox/*/storage"
    ]
    ++ [
      "/root/.cache"
      "/var/lib/docker"
      "/var/log/journal"
      "/var/cache"
      "/var/tmp"
      "/var/log"
    ];
  mkDailyBorgJob = paths: mkBorgJob { paths = paths; };
  mkBorgJob =
    {
      paths,
      startAt ? "daily",
    }:
    {
      paths = paths;
      exclude = excludeList;
      doInit = true;
      repo = "ssh://borg@server-hp-omen:22/mnt/WD_8tb/server/data/borg/slimbook";
      encryption = {
        mode = "repokey-blake2";
        passphrase = "prolonged ranting unhinge surviving herself energetic grievous reimburse trophy undermost enrage outmost";
      };
      environment.BORG_RSH = "ssh -i /home/lucasfa/.ssh/id_ed25519_borg_home_lucasfa";
      environment.BORG_EXIT_CODES = "modern";
      compression = "auto,zstd";

      startAt = startAt;
      prune.keep = {
        within = "3d";
        daily = 7;
        weekly = 4;
        monthly = 2;
      };
    };
in
{
  imports = [
    ./persistent.nix
  ];
  services.borgbackup.jobs.home-lucafa = mkDailyBorgJob [ "/home/lucasfa" ];
  services.borgbackup.jobs.system = mkDailyBorgJob [
    "/var"
    "/root"
  ];
}
