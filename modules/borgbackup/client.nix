{
  pkgs,
  lib,
  ...
}:
let
  defaultPaths = [
    "/home"
    "/etc"
    "/var"
    "/root"
    "/etc/group"
    "/etc/machine-id"
    "/etc/NetworkManager/system-connections"
    "/etc/passwd"
    "/etc/subgid"
  ];
  excludeList = [
    "*/cache2" # firefox
    "*/Cache"
    ".config/Code/CachedData"
    ".npm/_cacache"
    "*/node_modules"
    "*.pyc"
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
    "/var/lib/flatpak"
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
      repo ? "ssh://borg@server-hp-omen:22/mnt/WD_8tb/server/data/borg/slimbook",
      persistentTimer ? true,
      removableDevice ? false,
    }:
    {
      paths = paths;
      exclude = excludeList;
      doInit = false;
      repo = repo;
      encryption = {
        mode = "repokey-blake2";
        passphrase = "prolonged ranting unhinge surviving herself energetic grievous reimburse trophy undermost enrage outmost";
      };
      environment = {
        BORG_RSH = "ssh -i /home/lucasfa/.ssh/id_ed25519_borg_home_lucasfa";
        BORG_EXIT_CODES = "modern";
        # BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes"; # for moved repo warning
      };
      compression = "auto,zstd";

      startAt = startAt;
      persistentTimer = persistentTimer;
      removableDevice = removableDevice;
      prune.keep = {
        within = "3d";
        daily = 7;
        weekly = 4;
        monthly = 2;
      };
    };
in
{
  services.borgbackup.jobs.system = mkDailyBorgJob defaultPaths;
  services.borgbackup.jobs.local_backup = mkBorgJob {
    paths = defaultPaths;
    startAt = [ ]; # Run only manually
    repo = "/run/media/lucasfa/WD/borg_backups/slimbook";
    removableDevice = true;
    persistentTimer = false;
  };
}
