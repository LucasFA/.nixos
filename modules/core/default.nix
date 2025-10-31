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
    ./utils.nix
    ./nixpkgs.nix
    ./agenix
    ./zram
    ./hardening.nix
  ];

  services.thermald.enable = true;
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
  fonts.packages =
    with pkgs.nerd-fonts;
    [
      jetbrains-mono
      ubuntu
    ]
    ++ [
      pkgs.ubuntu-themes
      pkgs.ubuntu-sans
    ];
}
