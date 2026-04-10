{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.lfa.roles.desktop;
in
{
  config = lib.mkIf cfg.enable {
    # Fix a popup on startup regarding non-mathching login and keyring passwords
    security.pam.services.gdm.enableGnomeKeyring = true;
  };
}
