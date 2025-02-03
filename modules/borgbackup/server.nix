{
  pkgs,
  lib,
  ...
}:
{
  services.borgbackup.repos.home-lucafa = {
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEwhJlxsj16mbf4OwTsGYlFD1uLMAwpWGQ7YGy70Fwp lucasfa@slimbook Backup of /home/lucasfa"
    ];
    path = "/mnt/WD_8tb/server/data/borg/home-lucasfa-slimbook";
  };
}
