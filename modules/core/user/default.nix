{ lib, config, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucasfa = {
    isNormalUser = true;
    description = "Lucas";
    extraGroups = [
      "networkmanager"
      "wheel"
    ] ++ lib.optional config.virtualisation.docker.enable "docker";
  };
  users.users.root.extraGroups = lib.optional config.virtualisation.docker.enable "docker";
}
