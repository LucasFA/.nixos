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
    uv
    gnome-boxes
  ];
}
