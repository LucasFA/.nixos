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
    # general caches
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
    # /, /var
    "/root/.cache"
    "/var/lib/docker"
    "/var/lib/flatpak"
    "/var/log/journal"
    "/var/cache"
    "/var/tmp"
    "/var/log"
  ]
  ++ [
    # Home folder stuffs
    "/home/*/Downloads"
    "/home/*/games"
    "/home/*/.local/share/Paradox Interactive/*/shadercache" # eg Victoria 3
    "/home/*/.config/rpcs3/*/caches" # I think shader caches
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
  defaultExtraBackupArgs = [
    "--exclude-caches"
    "--exclude-if-present .nobackuplucasfa"
    "--cleanup-cache"
  ];
  backupJobTemplate = {
    paths = backupPaths;
    user = "lucasfa";
    exclude = excludeList;
    passwordFile = config.age.secrets."restic/passwordFile".path;
    pruneOpts = pruneOpts;
    timerConfig = defaultTimer;
    extraBackupArgs = defaultExtraBackupArgs;
  };
in
{
  # environment.systemPackages = with pkgs; [ restic ];
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

  age.secrets."restic/backblazeCredentials" = {
    file = ./../../secrets/restic/backblazeCredentials.age;
    owner = "lucasfa";
    group = "users";
  };

  systemd.services.restic-backups-nuc1.environment.GOMAXPROCS = "8";
  systemd.services.restic-backups-backblaze.environment.GOMAXPROCS = "8";
  # To run restic on a shell use the NixOS provided wrapper: `restic-<name>`, where <name>
  # is services.restic.backups.<name>. For example, restic-nuc1 or restic-backblaze
  services.restic.backups = {
    backblaze = backupJobTemplate // {
      initialize = false;
      repository = "s3:https://s3.eu-central-003.backblazeb2.com/slimbook-laptop";
      environmentFile = config.age.secrets."restic/backblazeCredentials".path;
    };

    nuc1 = backupJobTemplate // {
      initialize = false;
      repository = "rest:http://server-nuc1:8000/lucasfa";
      environmentFile = config.age.secrets."restic/environmentFile".path;
      progressFps = 0.02;
    };
  };
}
