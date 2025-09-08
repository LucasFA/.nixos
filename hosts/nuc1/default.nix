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
  ];
  boot.kernelPatches = [
    # Fix the /proc/net/tcp seek issue
    # Impacts tailscale: https://github.com/tailscale/tailscale/issues/16966
    {
      name = "proc: fix missing pde_set_flags() for net proc files";
      patch = pkgs.fetchurl {
        name = "fix-missing-pde_set_flags-for-net-proc-files.patch";
        url = "https://patchwork.kernel.org/project/linux-fsdevel/patch/20250821105806.1453833-1-wangzijie1@honor.com/raw/";
        hash = "sha256-DbQ8FiRj65B28zP0xxg6LvW5ocEH8AHOqaRbYZOTDXg=";
      };
    }
  ];

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
