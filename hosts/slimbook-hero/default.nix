{
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/core
    ../../modules/installed_programs.nix
    ../../modules/nix.nix

    ./hardware-configuration.nix
    ./boot.nix
    ./nvidia.nix
    ./filesystems.nix
    ./zram.nix
  ];

  networking.hostName = "slimbook";
}
