{ config, pkgs, ... }:
{
  programs = {
    bash.enable = true;
    fish.enable = true;
  };
  home.shellAliases = {
    gs = "git status";
  };
}
