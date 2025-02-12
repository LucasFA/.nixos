{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./nvidia.nix
    ./filesystems.nix
    ./zram.nix
    ./power.nix
  ];
}
