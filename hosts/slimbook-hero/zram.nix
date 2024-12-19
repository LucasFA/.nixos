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
}
