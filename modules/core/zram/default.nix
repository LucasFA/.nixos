{
  config,
  lib,
  pkgs,
  ...
}:

{
  zramSwap = {
    enable = lib.mkDefault true;
    memoryPercent = lib.mkDefault 50;
    algorithm = lib.mkDefault "lz4";
  };
  boot.kernel.sysctl = {
    "vm.page-cluster" = lib.mkDefault 1;
  };
}
