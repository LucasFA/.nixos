{
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

  environment.systemPackages = [
    dduper
  ];

  services.udisks2.enable = true;
  # As there is no DE, this has to be manually set in order to install intel-media-driver et al
  hardware.graphics.enable = true;
  networking.firewall = {
    allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport. Wireguard
  };

  age.secrets = {
    protonVPNPrivateKeyFile = {
      file = ./../../secrets/protonVPNPrivateKeyFile.age; # config.age.secrets.protonVPNPrivateKeyFile.path;
      owner = "root";
      group = "root";
    };
  };
  networking.wireguard = {
    enable = false;
    interfaces = {
      wg0 = {
        ips = [ "10.2.0.2/32" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.protonVPNPrivateKeyFile.path;
        peers = [
          {
            publicKey = "QkRTXcTgRJGTjSFe/Qaa8l6hi7NbITvGFRSdhUpMvSw=";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "185.246.211.72:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
