{
  self,
  config,
  pkgs,
  lib,
  ...
}:
let
  backupPaths = [ "/home/lucasfa" ];
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
  backblazeBackupJob = backupJobTemplate // {
    repository = "s3:https://s3.eu-central-003.backblazeb2.com/lucasfa-backups";
    environmentFile = config.age.secrets."restic/backblazeCredentials".path;
  };

  nuc1BackupJob =
    subrepositoryName:
    backupJobTemplate
    // {
      repository = "rest:https://restic.lucasfa.com/lucasfa/" + subrepositoryName;
      environmentFile = config.age.secrets."restic/environmentFile".path;
      progressFps = 0.02;
    };
in
{
  options.modules.restic.backups.immich = lib.mkOption {
    description = ''
      Will configure restic services to backup the immich directory.
    '';
    type = lib.types.bool;
    default = false;
  };
  options.modules.restic.backups.personalLaptop = lib.mkOption {
    description = ''
      Will configure restic services to backup the /home/lucasfa directory.
    '';
    type = lib.types.bool;
    default = false;
  };
  options.modules.restic.desktopNotification = lib.mkOption {
    description = ''
      Notify the user using a desktop notification
    '';
    type = lib.types.bool;
    default = true;
  };

  config = {
    age.secrets =
      let
        lucasfaOwnedAgeSecret = {
          owner = "lucasfa";
          group = "users";
        };
      in
      {
        "restic/passwordFile" = lucasfaOwnedAgeSecret // {
          file = self.outPath + "/secrets/restic/passwordFile.age";
        };
        "restic/environmentFile" = lucasfaOwnedAgeSecret // {
          file = self.outPath + "/secrets/restic/environmentFile.age";
        };
        "restic/backblazeCredentials" = lucasfaOwnedAgeSecret // {
          file = self.outPath + "/secrets/restic/backblazeCredentials.age";
        };
      };
    # environment.systemPackages = with pkgs; [ restic ];

    # To run restic on a shell use the NixOS provided wrapper: `restic-<name>`, where <name>
    # is services.restic.backups.<name>. For example, restic-nuc1 or restic-backblaze
    services.restic.backups =
      let
        serverOverrides = {
          paths = [ "/mnt/WD_8tb/server/data/immich" ];
          user = "restic";
          package = pkgs.writeShellScriptBin "restic" ''
            exec /run/wrappers/bin/restic "$@"
          '';
        };
      in
      lib.mkMerge [
        (lib.mkIf config.modules.restic.backups.personalLaptop {
          backblaze = backblazeBackupJob;
          backblaze-check = mkMonthlyCheckJob backblazeBackupJob;
          nuc1 = (nuc1BackupJob "slimbook-laptop");
          nuc1-check = mkMonthlyCheckJob (nuc1BackupJob "slimbook-laptop");
        })
        (lib.mkIf config.modules.restic.backups.immich {
          backblaze = backblazeBackupJob // serverOverrides;
          nuc1 = (nuc1BackupJob "immich") // serverOverrides;
        })
      ];

    users.users.restic = {
      isSystemUser = true;
      group = "restic";
    };
    users.groups.restic = { };

    security.wrappers.restic = {
      source = "${pkgs.restic.out}/bin/restic";
      owner = "restic";
      group = "users";
      permissions = "u=rwx,g=,o=";
      capabilities = "cap_dac_read_search=+ep";
    };

    # systemd.services.restic-backups-nuc1.environment.GOMAXPROCS = lib.mkForce "8";
    # systemd.services.restic-backups-nuc1-check.environment.GOMAXPROCS = lib.mkForce "8";
    # systemd.services.restic-backups-backblaze.environment.GOMAXPROCS = lib.mkForce "8";
    # systemd.services.restic-backups-backblaze-check.environment.GOMAXPROCS = lib.mkForce "8";

    # Notification in case of failures
    environment.systemPackages = lib.mkIf config.modules.restic.desktopNotification [
      pkgs.libnotify
    ];
    systemd.services = lib.mkIf config.modules.restic.desktopNotification {
      restic-backups-nuc1.unitConfig.OnFailure = "notify-backup-failed-nuc1.service";
      "notify-backup-failed-nuc1" = mkNotifyFailedBackupService "nuc1";

      restic-backups-backblaze.unitConfig.OnFailure = "notify-backup-failed-backblaze.service";
      "notify-backup-failed-backblaze" = mkNotifyFailedBackupService "backblaze";
    };
  };
}
