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
    onlyoffice-desktopeditors
    uv
    gnome-boxes
  ];
}
