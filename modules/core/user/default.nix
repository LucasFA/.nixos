{ lib, config, ... }:
let
  virt = config.virtualisation;
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucasfa = {
    isNormalUser = true;
    description = "Lucas";
    extraGroups = [
      "networkmanager"
      "wheel"
    ]
    ++ lib.optional virt.docker.enable "docker"
    ++ lib.optional (virt.podman.enable && virt.podman.dockerSocket.enable) "podman";
  };
  users.users.root.extraGroups = lib.optional config.virtualisation.docker.enable "docker";
}
