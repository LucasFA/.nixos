{ lib, ... }:
{
  # services.automatic-timezoned.enable = lib.mkDefault true; # never got it to work
  time.timeZone = lib.mkForce null; # set by user
}
