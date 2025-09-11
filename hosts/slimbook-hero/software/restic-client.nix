{
  self,
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
    Persistent = true;
    RandomizedDelaySec = "1h";
  };
  monthlyTimer = defaultTimer // {
    OnCalendar = "monthly";
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
    runCheck = true;
    # Backblaze B2 pricing: 1G daily free egress + 300% of average monthly storage free egress # (IDK which it is...)
    checkOpts = [ ];
    timerConfig = defaultTimer;
    extraBackupArgs = defaultExtraBackupArgs;
  };

  mkMonthlyCheckJob =
    job:
    job
    // {
      timerConfig = monthlyTimer;
      checkOpts = [ "--read-data" ];
    };

  defaultNotifySet = {
    enable = true;
    description = "Notify on failed backup";
    serviceConfig = {
      Type = "oneshot";
      User = config.users.users.lucasfa.name;
    };

    # required for notify-send
    environment.DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${
      toString (if config.users.users.lucasfa.uid == null then 1000 else config.users.users.lucasfa.uid)
    }/bus";
  };
  mkNotifyFailedBackupService =
    suffix:
    defaultNotifySet
    // {
      description = "Notify on failed backup to " + suffix;
      script = ''
        ${pkgs.libnotify}/bin/notify-send --urgency=critical \
          "Backup failed" \
          "$(journalctl -u restic-backups-${suffix} -n 5 -o cat)"
      '';
    };
  lucasfaOwnedAgeSecret = {
    owner = "lucasfa";
    group = "users";
  };
  backblazeBackupJob = backupJobTemplate // {
    repository = "s3:https://s3.eu-central-003.backblazeb2.com/lucasfa-backups";
    environmentFile = config.age.secrets."restic/backblazeCredentials".path;
  };

  nuc1BackupJob = backupJobTemplate // {
    repository = "rest:https://restic.lucasfa.com/lucasfa/slimbook-laptop";
    environmentFile = config.age.secrets."restic/environmentFile".path;
    progressFps = 0.02;
  };
in
{
  # environment.systemPackages = with pkgs; [ restic ];
  age.secrets."restic/passwordFile" = lucasfaOwnedAgeSecret // {
    file = self.outPath + "/secrets/restic/passwordFile.age";
  };

  age.secrets."restic/environmentFile" = lucasfaOwnedAgeSecret // {
    file = self.outPath + "/secrets/restic/environmentFile.age";
  };

  age.secrets."restic/backblazeCredentials" = lucasfaOwnedAgeSecret // {
    file = self.outPath + "/secrets/restic/backblazeCredentials.age";
  };

  systemd.services.restic-backups-nuc1.environment.GOMAXPROCS = "8";
  systemd.services.restic-backups-nuc1-check.environment.GOMAXPROCS = "8";
  systemd.services.restic-backups-backblaze.environment.GOMAXPROCS = "8";

  # To run restic on a shell use the NixOS provided wrapper: `restic-<name>`, where <name>
  # is services.restic.backups.<name>. For example, restic-nuc1 or restic-backblaze
  services.restic.backups = {
    backblaze = backblazeBackupJob;
    backblaze-check = mkMonthlyCheckJob backblazeBackupJob;
    nuc1 = nuc1BackupJob;
    nuc1-check = mkMonthlyCheckJob nuc1BackupJob;
  };

  # Notification in case of failures
  environment.systemPackages = [
    pkgs.libnotify
  ];

  systemd.services.restic-backups-nuc1.unitConfig.OnFailure = "notify-backup-failed-nuc1.service";
  systemd.services."notify-backup-failed-nuc1" = mkNotifyFailedBackupService "nuc1";

  systemd.services.restic-backups-backblaze.unitConfig.OnFailure =
    "notify-backup-failed-backblaze.service";
  systemd.services."notify-backup-failed-backblaze" = mkNotifyFailedBackupService "backblaze";
}
