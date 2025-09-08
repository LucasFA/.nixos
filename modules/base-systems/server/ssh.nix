{
  lib,
  config,
  ...
}:
{
  # By default tailscale,
  services.tailscale.enable = lib.mkForce true; # #### allowNoPasswordLogin allows to have no SSH keys for root or any
  users.allowNoPasswordLogin = true; # ### wheel group user. Therefore, force tailscale: otherwise locked out
  services.tailscale.openFirewall = true; # networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # but you can also log in through standard SSH. If no port forwarding in the router, at least in the LAN
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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8s/0c98/d6Q6SkPTzKS0S7lm26uIywus/YNXKs3Ayp" # Slimbook lucasfa
  ];
}
