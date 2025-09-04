{
  config,
  lib,
  pkgs,
  ...
}:

{
  zramSwap = {
    memoryPercent = 66;
  };
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0;
    "vm.swappiness" = 150;
    "vm.watermark_scale_factor" = 100; # See https://github.com/pop-os/default-settings/pull/163
  };
}
