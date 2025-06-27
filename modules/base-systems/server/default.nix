{ pkgs, lib, ... }:

{
  imports = [
    ../../borgbackup/server.nix
    # ../../forgejo
  ];
  virtualisation.docker.enable = true;
  services.openssh.enable = lib.mkForce false;
}
