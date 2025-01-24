{
  inputs,
  pkgs,
  lib,
  ...
}:
{

  imports = [
    ../../modules/core
    ../../modules/base-systems/server
    ./configuration.nix
    ./hardware-configuration.nix
    ./wol.nix
  ];
  environment.systemPackages = [
    inputs.compose2nix.packages.x86_64-linux.default
  ];
  services.tailscale.enable = lib.mkForce true; # #### allowNoPasswordLogin allows to have no SSH keys for root or any
  users.allowNoPasswordLogin = true; # ### wheel group user. Therefore, force tailscale: otherwise locked out
  services.openssh.enable = lib.mkForce false; # Rely exclusively on tailscale
  networking.hostName = "server-hp-omen";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
