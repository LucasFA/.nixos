{
  config,
  lib,
  pkgs,
  ...
}:

{
  zramSwap = {
    enable = true;
    memoryPercent = 90;
    algorithm = "zstd";
  };
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0;
  };
}
