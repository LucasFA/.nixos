{ pkgs, lib, config, ... }:

{
  imports = [
    ../../borgbackup/server.nix
    # ../../forgejo
  ];
  virtualisation.docker.enable = true;
  services.openssh.enable = lib.mkForce false;
  networking.networkmanager.ethernet.macAddress = "stable";

  services.tailscale.enable = lib.mkForce true; # #### allowNoPasswordLogin allows to have no SSH keys for root or any
  users.allowNoPasswordLogin = true; # ### wheel group user. Therefore, force tailscale: otherwise locked out
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
}
