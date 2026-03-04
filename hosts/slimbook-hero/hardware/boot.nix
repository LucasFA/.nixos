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
  boot.kernelPackages = pkgs.linuxPackages_6_12;
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

  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  #boot.kernelPackages = pkgs.linuxKernel_latest;
  boot.kernel.sysctl."kernel.sysrq" = 1;

  boot.kernelParams = [ ];

  boot.loader.grub = {
    enable = false;
    copyKernels = false; # no need: uses them straight from /nix/store
    configurationLimit = confLimit;
    useOSProber = true;
    efiSupport = true;
    #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
    device = "nodev";
    font = "${pkgs.fira-code}/share/fonts/truetype/FiraCode-VF.ttf";
    fontSize = 36;
    extraEntries = ''
                      menuentry "Reboot" {
                          reboot
                      }
       		menuentry "Poweroff" {
                          halt
                      }
      		'';
  };
}
