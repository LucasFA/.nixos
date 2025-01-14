{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./locale.nix
    ./autoupgrade.nix
    ./gnome
    ./nix.nix
    ./networking.nix
    ./sound.nix
  ];

  programs.firefox.enable = true;
  # Enable CUPS to print documents.
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    # Development
    vim
    tealdeer
    nvd
    nix-inspect

    # System utilities
    wl-clipboard
    gparted
    btrfs-progs
    dconf

    # Nix utils
    nix-output-monitor
    nixfmt-rfc-style
  ];
}
