{ pkgs, ... }:

{
  imports = [
    ./base-systems/personal
    ./base-systems/gaming
    ./base-systems/development
    ./misc.nix
  ];
}
