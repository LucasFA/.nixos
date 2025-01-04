{
  pkgs,
  config,
  lib,
  ...
}:
{
  services.switcherooControl.enable = true;
  hardware.nvidia = {
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
}
