{
  config,
  lib,
  pkgs,
  ...
}:
let
  confLimit = 10;
in
{
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.extraModulePackages = with config.boot.kernelPackages; [ qc71_slimbook_laptop ];
  boot.kernelModules = [ "qc71_laptop" ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.timeout = lib.mkForce 1;

  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    memtest86.enable = true;
    configurationLimit = confLimit;
  };

  boot.kernel.sysctl."kernel.sysrq" = 1;

  boot.kernelParams = [ ];
}
