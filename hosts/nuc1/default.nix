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
  ];
}
