{
  pkgs,
  lib,
  config,
  ...
}:
{
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
    autoprune = {
      enable = true;
      flags = [ "--all" ];
    };
    rootless = {
      enable = false;
      setSocketVariable = true;
    };
  };
  security.wrappers.docker-rootlesskit = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_bind_service+ep";
    source = "${pkgs.rootlesskit}/bin/rootlesskit";
  };
}
