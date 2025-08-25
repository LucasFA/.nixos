{
  lib,
  config,
  ...
}:

{
  imports = [
    # ../../forgejo
    ./ssh.nix
    ./dns.nix
    ./docker.nix
  ];

  networking.networkmanager.ethernet.macAddress = "stable";
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

}
