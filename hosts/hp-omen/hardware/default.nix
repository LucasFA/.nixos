# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/WD_8tb
  ];
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/e9407266-6514-4e96-8797-1667f344023c";
    fsType = "btrfs";
    options = [
      "noatime"
    ];
  };
}
