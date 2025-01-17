{
  pkgs,
  lib,
  ...
}:
{

  imports = [
    ../../modules/core
    ./configuration.nix
    ./hardware-configuration.nix
    ./wol.nix
  ];

  services.tailscale.enable = lib.mkForce true; # #### This settings allows to have no SSH keys for root or wheel group
  users.allowNoPasswordLogin = true; # ### therefore, force tailscale: very dangerous otherwise
  networking.hostName = "server-hp-omen";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
