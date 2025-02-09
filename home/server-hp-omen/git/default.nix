{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.git = {
    extraConfig = {
      user.signingKey = lib.mkForce "/home/lucasfa/.ssh/id_ed25519.pub";
    };
  };
}
