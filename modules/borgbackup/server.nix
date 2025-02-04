{
  pkgs,
  lib,
  ...
}:
let
  slimbook_borg_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5kC93c4adHZUbRiSiGNAhb48UEQF73UoLsBg1SWT5j root@slimbook Borg backup of /home/lucasfa";
in
{
  programs.ssh.knownHosts."slimbook" = {
    hostNames = [ "slimbook" ];
    publicKey = slimbook_borg_ssh_key;
  };
  services.borgbackup.repos.slimbook = {
    authorizedKeys = [
      slimbook_borg_ssh_key
    ];
    path = "/mnt/WD_8tb/server/data/borg/slimbook";
  };
}
