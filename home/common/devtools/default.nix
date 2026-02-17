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
  programs.yazi.shellWrapperName = "y";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      # LazyVim
    ];
  };
}
