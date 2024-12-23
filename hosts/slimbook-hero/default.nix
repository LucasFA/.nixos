{
  pkgs,
  ...
}:

{
  imports = [
    # nixos-hardware.nixosModules.slimbook-hero-rpl-rtx
    ./gnome-fix.nix
    ./boot.nix
    ./nvidia.nix
    ./filesystems.nix
    ./zram.nix
  ];

}
