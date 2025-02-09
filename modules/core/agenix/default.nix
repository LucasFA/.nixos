{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages."${system}".default
  ];
  age.identityPaths = [
    "/home/lucasfa/.ssh/id_ed25519_lucasfa"
    "/home/lucasfa/.ssh/id_ed25519"
    "/etc/ssh/id_ed25519"
  ];
}
