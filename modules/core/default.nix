{
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

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
