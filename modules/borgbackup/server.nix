{
  pkgs,
  lib,
  ...
}:
let
  slimbook_borg_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEwhJlxsj16mbf4OwTsGYlFD1uLMAwpWGQ7YGy70Fwp lucasfa@slimbook Backup of /home/lucasfa";
in
{
  programs.ssh.knownHosts."slimbook" = {
    hostNames = [ "slimbook" ];
    publicKey = slimbook_borg_ssh_key;
  };
  services.borgbackup.repos.home-lucafa = {
    authorizedKeys = [
      slimbook_borg_ssh_key
    ];
    path = "/mnt/WD_8tb/server/data/borg/home-lucasfa-slimbook";
  };
}
