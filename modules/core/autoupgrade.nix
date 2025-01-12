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
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
      "--print-build-logs"
    ];
    randomizedDelaySec = "15min";
  };
}
