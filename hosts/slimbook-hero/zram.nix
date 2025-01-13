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
    priority = 120;
  };
}
