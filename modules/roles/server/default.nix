{
  lib,
  config,
  ...
}:
let
  cfg = config.lfa.roles.server;
in
{
  imports = [
    ./WD_8tb.nix
  ];
  options.lfa.roles.server.enable = lib.mkEnableOption "server role (ssh, docker, sftpgo, etc.)";

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
    networking.networkmanager.ethernet.macAddress = "stable";
    networking.firewall.allowedTCPPorts = [
      21 # ftp
      80
      443
    ];

    # SSH
    services.tailscale.enable = lib.mkForce true;
    users.allowNoPasswordLogin = true;
    services.tailscale.openFirewall = true;
    services.fail2ban.enable = false;
    services.openssh = {
      enable = lib.mkForce true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "lucasfa" ];
      };
    };
    users.users.lucasfa.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8s/0c98/d6Q6SkPTzKS0S7lm26uIywus/YNXKs3Ayp" # Slimbook lucasfa
    ];

    # Docker
    virtualisation.podman = {
      enable = false;
      dockerSocket.enable = true;
    };
    environment.shellAliases = {
      "dc" = "docker compose";
      "dcu" = "docker compose up -d";
      "dcd" = "docker compose down";
      "dceu" = "docker compose --env-file=../.env up -d";
    };
    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
      rootless = {
        enable = false;
        setSocketVariable = true;
      };
    };

    # SFTPGo
    users.groups.mediacenter = {
      gid = 13000;
      members = [ "sftpgo" ];
    };
    services.sftpgo = {
      enable = true;
      group = "mediacenter";
      dataDir = "/mnt/WD_8tb/server/data/sftpgo";
      settings =
        let
          defaultOpts = {
            address = "localhost";
            port = 800;
          };
        in
        {
          ftpd.bindings = [
            {
              address = "localhost";
              port = 801;
            }
          ];
          httpd.bindings = [
            defaultOpts
          ];
        };
    };

    # DNS (AdGuardHome) - disabled
    services.resolved.settings.Resolve = {
      DNS = [ "127.0.0.1" ] ++ config.networking.nameservers;
      DNSStubListener = "no";
    };

    # n8n - disabled
    services.n8n = {
      enable = false;
      openFirewall = false;
      environment.WEBHOOK_URL = "https://n8n.lucasfa.com/";
    };
    systemd.services.n8n.environment.N8N_LISTEN_ADDRESS = "127.0.0.1";
    boot.kernelModules = [ "tcp_bbr" ];
    boot.kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };
  };
}
