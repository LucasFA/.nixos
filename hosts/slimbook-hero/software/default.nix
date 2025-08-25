{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ../../../modules/core
    ../../../modules/base-systems/personal
    ../../../modules/base-systems/work
    ../../../modules/base-systems/gaming
    ../../../modules/base-systems/development
    ../../../modules/restic/client.nix
    ../../../modules/misc.nix
  ];

  networking.hostName = "slimbook";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "lucasfa";
  services.displayManager.defaultSession = "gnome";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;
}
