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
    ./shells.nix
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    # Development
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
