{
  lib,
  config,
  inputs,
  ...
}:

let
  profiles = (import ../../modules/home/profiles.nix).profiles;
in
{
  imports = [ ../../modules/home ];

  # Minimal home configuration for server use
  lfa.home = profiles.server;

  home.username = "lucasfa";
  home.homeDirectory = "/home/lucasfa";
}
