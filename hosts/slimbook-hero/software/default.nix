{
  hostRole,
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ../../../modules/core
    ../../../modules/restic/client.nix
    ./secureboot.nix
  ];
  lfa.hostRole = hostRole;
  lfa.backups.personalLaptop.enable = true;

  # Slimbook-specific Spanish government authentication
  programs.autofirma = {
    enable = false;
    firefoxIntegration.enable = true;
  };
  programs.configuradorfnmt = {
    enable = true;
    firefoxIntegration.enable = true;
  };
  programs.firefox.policies.SecurityDevices = {
    "OpenSC PKCS#11" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    "DNIeRemote" = "${config.programs.dnieremote.finalPackage}/lib/libdnieremotepkcs11.so";
  };

  networking.hostName = "slimbook";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;
}
