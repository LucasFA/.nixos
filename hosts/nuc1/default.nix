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
            publicKey = "Z/l/+DAz1YilevRfmEMMjNbzYOVCB0sOJc3vVKhQ/gw=";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "62.169.136.220:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
