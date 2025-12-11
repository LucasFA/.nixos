{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ./vm.nix
  ];
  environment.systemPackages = with pkgs; [
    gnome-boxes
  ];
}
