{
  inputs,
  pkgs,
  lib,
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
  #networking.wireguard = {
    #enable = true;
    #interfaces = {
      #wg0 = {
        #ips = ["10.2.0.2/32"];
        #listenPort = 51820;

}
