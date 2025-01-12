{
lib
}:
{
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
      "--print-build-logs"
    ];
    randomizedDelaySec = "15min";
  };
}
