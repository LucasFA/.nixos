{
  config,
  lib,
  ...
}:
{
  config.systemd.timers = lib.flip lib.mapAttrs' config.services.borgbackup.jobs (
    name: value:
    lib.nameValuePair "borgbackup-job-${name}" {
      timerConfig.Persistent = lib.mkForce true;
    }
  );
}
