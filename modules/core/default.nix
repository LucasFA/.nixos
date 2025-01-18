{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./user
    ./locale.nix
    ./autoupgrade.nix
    ./nix.nix
    ./networking.nix
    ./sound.nix
    ./shells.nix
  ];

  services.xserver = {
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    # Development
    nix-inspect

    # System utilities
    btrfs-progs
    dconf

    # Nix utils
    nix-output-monitor
    nixfmt-rfc-style
  ];
}
