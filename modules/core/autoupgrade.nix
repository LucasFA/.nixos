{
  config,
  lib,
  ...
}:
{
  system.autoUpgrade = {
    enable = lib.mkDefault false; # man I wish didn't result in a) compiling huge things, sometimes, and b) making a ton of noise
    flake = "github:LucasFA/.nixos";
    flags = [
      "--print-build-logs"
    ];
    randomizedDelaySec = "15min";
  };
}
