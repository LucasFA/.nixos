{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Fix a popup on startup regarding non-mathching login and keyring passwords
  security.pam.services.gdm.enableGnomeKeyring = true;
}
