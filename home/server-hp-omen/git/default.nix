{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.git = {
    extraConfig = {
      user.signingKey = "/home/lucasfa/.ssh/id_ed25519";
    };
  };
}
