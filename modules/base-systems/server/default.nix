{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ../../borgbackup/server.nix
    # ../../forgejo
  ];
  virtualisation.docker.enable = true;
  services.fail2ban.enable = true;
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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8s/0c98/d6Q6SkPTzKS0S7lm26uIywus/YNXKs3Ayp"
  ];
  networking.networkmanager.ethernet.macAddress = "stable";

  services.tailscale.enable = lib.mkForce true; # #### allowNoPasswordLogin allows to have no SSH keys for root or any
  users.allowNoPasswordLogin = true; # ### wheel group user. Therefore, force tailscale: otherwise locked out
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
}
