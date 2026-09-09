{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.lfa.roles.server;
in
{
  config = lib.mkIf cfg.enable {
    services.snapraid = {
      enable = false;

    };
  };
}
