{
  lib,
  config,
  ...
}:

{
  imports = [
    ../../borgbackup/server.nix
    # ../../forgejo
    ./ssh.nix
    ./dns.nix
  ];
  virtualisation.docker.enable = true;
  networking.networkmanager.ethernet.macAddress = "stable";

}
