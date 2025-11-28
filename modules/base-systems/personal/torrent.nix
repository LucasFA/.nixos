{
  pkgs,
  lib,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    qbittorrent
    protonvpn-gui
  ];
  networking.firewall.allowedUDPPorts = [
    6882
    6771
  ]; # qBittorrent and Local peer discovery
  networking.firewall.allowedTCPPorts = [ 6882 ];
  networking.wireguard.enable = true;

}
