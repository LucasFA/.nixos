{
  self,
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  dduper = pkgs.callPackage ./dduper.nix { };
in
{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
    ../../modules/WD_8tb
    ../../modules/core
    ../../modules/base-systems/server
    ../../modules/restic/server.nix
    ../../modules/restic/client.nix
  ];
  lfa.backups.immich.enable = true;
  lfa.backups.desktopNotification.enable = false;
  environment.systemPackages = [
    dduper
  ];

  services.udisks2.enable = true;
  # As there is no DE, this has to be manually set in order to install intel-media-driver et al
  hardware.graphics.enable = true;
  networking.firewall = {
    allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport. Wireguard
  };
}
