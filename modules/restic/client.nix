{
  pkgs,
  lib,
  ...
}:
let
  defaultPaths = [
    "/home"
    "/etc"
    "/var"
    "/root"
    "/etc/group"
    "/etc/machine-id"
    "/etc/NetworkManager/system-connections"
    "/etc/passwd"
    "/etc/subgid"
  ];
  excludeList =
    [
      "*/cache2" # firefox
      "*/Cache"
      ".config/Code/CachedData"
      ".npm/_cacache"
      "*/node_modules"
      "*.pyc"
      "/home/lucasfa/games"
      "/home/*/.direnv"
      "/home/*/.cache"
      "/home/*/.cargo"
      "/home/*/.npm"
      "/home/*/.mozilla/firefox/*/storage"
    ]
    ++ [
      "/root/.cache"
      "/var/lib/docker"
      "/var/lib/flatpak"
      "/var/log/journal"
      "/var/cache"
      "/var/tmp"
      "/var/log"
    ];
in 
{
}
