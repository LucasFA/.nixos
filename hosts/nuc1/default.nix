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

}
