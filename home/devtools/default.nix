{ pkgs, ... }:
{
  home.packages = with pkgs; [
    shellcheck
    nixpkgs-review
  ];
  programs.eza = {
    enable = true;
    git = true;
  };
}
