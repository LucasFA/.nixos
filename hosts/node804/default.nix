{
  self,
  inputs,
  hostRole,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
    ./smart-temperature.nix
    ../../modules/core
    ../../modules/restic/server.nix
  ];
  lfa.hostRole = hostRole;
  lfa.roles.server.disk_pool.enable = true;
  lfa.roles.server.WD_8tb.enable = true;

  services.udisks2.enable = true;
  # As there is no DE, this has to be manually set in order to install intel-media-driver et al
  hardware.graphics.enable = true;
  networking.firewall = {
    allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport. Wireguard
  };

  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure

    # defaults:
    # "zswap.compressor=zstd"
    # "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
  ];
}
