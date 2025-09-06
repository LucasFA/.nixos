{
  config,
  lib,
  ...
}:
{
  system.autoUpgrade = {
    # man I wish didn't result in a) compiling huge things, sometimes, and b) making a ton of noise
    enable = lib.mkDefault false;
    flake = "github:LucasFA/.nixos";
    flags = [
      "--print-build-logs"
    ];
    randomizedDelaySec = "15min";
  };
}
