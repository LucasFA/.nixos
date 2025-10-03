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
  programs.yazi.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      # LazyVim
    ];
  };
}
