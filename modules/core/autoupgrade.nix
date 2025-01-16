{
  config,
  lib,
  ...
}:
{
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    flake = "github:LucasFA/.nixos";
    flags = [
      "--print-build-logs"
    ];
    randomizedDelaySec = "15min";
  };
}
