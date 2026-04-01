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

  # Home configuration composed for desktop use
  lfa.home = profiles.desktop;

  home.username = "lucasfa";
  home.homeDirectory = "/home/lucasfa";
}
