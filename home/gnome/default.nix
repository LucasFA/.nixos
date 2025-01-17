{ lib, ... }:
{
  imports = [ ./dconf.nix ];

  services.caffeine.enable = true;
}
