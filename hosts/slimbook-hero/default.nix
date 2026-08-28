{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware
    ./software
  ];

  # services.automatic-timezoned.enable = lib.mkDefault true; # never got it to work
  time.timeZone = lib.mkForce null; # set by user

  systemd.sleep.settings.Sleep.MemorySleepMode = "deep";
  systemd.sleep.settings.Sleep.HibernateDelaySec = "30m";
  # SuspendState=mem
}
