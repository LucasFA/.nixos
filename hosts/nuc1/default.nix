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
  ];
}
