{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
    ../../modules/WD_8tb
    ../../modules/core
    ../../modules/base-systems/server
  ];
  
  hardware.graphics.enable = true; # as there is no DE, this has to be manually set in order to install intel-media-driver et al

  services.tailscale.enable = lib.mkForce true; # #### allowNoPasswordLogin allows to have no SSH keys for root or any
  users.allowNoPasswordLogin = true; # ### wheel group user. Therefore, force tailscale: otherwise locked out
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
}
