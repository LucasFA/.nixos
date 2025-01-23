{ lib, ... }:
{
  services.automatic-timezoned.enable = lib.mkDefault true;
}
