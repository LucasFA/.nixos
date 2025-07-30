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

  virtualisation.docker = {
    enable = true;
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
