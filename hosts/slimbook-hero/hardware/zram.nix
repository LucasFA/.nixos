{
  config,
  lib,
  pkgs,
  ...
}:

{
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0;
  };
}
