{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.git = {
    extraConfig = {
      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDSEUv/KiQ7b5JMCzL/muEYlSB5NB2+jb4mG1pDrikad";
    };
  };
}
