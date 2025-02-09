{ pkgs, ... }:

{
  imports = [
    ../../borgbackup/server.nix
    # ../../forgejo
  ];
  virtualisation.docker.enable = true;
}
