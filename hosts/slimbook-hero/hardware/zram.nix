{
  config,
  lib,
  pkgs,
  ...
}:

{
  zramSwap = {
    enable = true;
    memoryPercent = 66;
    algorithm = "lz4";
  };
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0;
    "vm.swappiness" = 150;
    "vm.watermark_scaling_factor" = 100; # See https://github.com/pop-os/default-settings/pull/163
  };
}
