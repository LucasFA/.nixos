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
    ./n8n.nix
    ./sftpgo.nix
    ./mautrix.nix
  ];

  networking.networkmanager.ethernet.macAddress = "stable";
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

}
