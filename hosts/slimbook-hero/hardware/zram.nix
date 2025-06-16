{
  config,
  lib,
  pkgs,
  ...
}:

{
  zramSwap = {
    enable = false;
    memoryPercent = 75;
    algorithm = "zstd";
  };
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0;
    "vm.swappiness" = 120;
  };
}
