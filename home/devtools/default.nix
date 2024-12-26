{ pkgs, ... }:
{
  home.packages = with pkgs; [
    shellcheck
  ];
  programs.eza = {
    enable = true;
    git = true;
  };
}
