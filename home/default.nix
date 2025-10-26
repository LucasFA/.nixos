{ config, pkgs, ... }:
{
  imports = [
    ./common
  ];
  services.vicinae = {
    enable = true; # default: false
    autoStart = true; # default: true
    # package = # specify package to use here. Can be omitted.
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = false;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";
}
