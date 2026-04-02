{
  lib,
  config,
  ...
}:

{
  imports = [
    # ../../forgejo
    ./ssh.nix
    ./docker.nix
    ./n8n.nix
    ./sftpgo.nix
  ];

  programs.nix-ld.enable = true;
  networking.networkmanager.ethernet.macAddress = "stable";
  networking.firewall.allowedTCPPorts = [
    21 # ftp
    80
    443
  ];

  # https://hub.docker.com/r/adguard/adguardhome#resolved-daemon
  services.resolved.extraConfig = "[Resolve]
DNS=127.0.0.1
DNSStubListener=no
";
}
