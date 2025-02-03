{ pkgs, ... }:

{
  imports = [
    ../../borgbackup/server.nix
  ];
  virtualisation.docker.enable = true;
}
