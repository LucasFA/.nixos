{
  pkgs,
  ...
}:

{
  imports = [
    # nixos-hardware.nixosModules.slimbook-hero-rpl-rtx
    ./gnome-fix.nix
    ./boot.nix
    ./opinionated_slimbook.nix
    ./nvidia.nix
    ./filesystems.nix
    ./zram.nix
  ];

}
