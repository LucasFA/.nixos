{
  config,
  pkgs,
  lib,
  ...
}:
let
  backupPaths = [ "/home/lucasfa" ];
  # defaultPaths = [
  # "/home"
  # "/etc"
  # "/var"
  # "/root"
  # "/etc/group"
  # "/etc/machine-id"
  # "/etc/NetworkManager/system-connections"
  # "/etc/passwd"
  # "/etc/subgid"
  # ];
  excludeList = [
    "*/cache2" # firefox
    "*/Cache"
    ".config/Code/CachedData"
    ".npm/_cacache"
    "*/node_modules"
    "*.pyc"

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
  ]
  ++ [
    "/home/*/Downloads"
    "/home/*/games"
    "/home/*/.local/share/*/shadercache" # eg Victoria 3
    "/home/*/.var" # flatpaks
    "/home/*/.local/share/Steam"
    "/home/*/torrents"
  ];
  defaultTimer = {
    OnCalendar = "daily";
    RandomizedDelaySec = "1h";
  };
  pruneOpts = [
    "--keep-daily 7"
    "--keep-weekly 5"
    "--keep-monthly 12"
    "--keep-yearly 2"
  ];
in
{
  age.secrets."restic/passwordFile" = {
    file = ./../../secrets/restic/passwordFile.age;
    owner = "lucasfa";
    group = "users";
  };

  age.secrets."restic/environmentFile" = {
    file = ./../../secrets/restic/environmentFile.age;
    owner = "lucasfa";
    group = "users";
  };

  systemd.services.restic-backups-nuc1.environment.GOMAXPROCS = "8";
  services.restic.backups = {
    # backblaze =
    nuc1 = {
      initialize = true; # ?
      paths = backupPaths;
      user = "lucasfa";
      exclude = excludeList;
      repository = "rest:http://server-nuc1:8000/lucasfa";
      passwordFile = config.age.secrets."restic/passwordFile".path;
      pruneOpts = pruneOpts;
      timerConfig = defaultTimer;
      environmentFile = config.age.secrets."restic/environmentFile".path;
      progressFps = 0.02;
    };
  };
}
