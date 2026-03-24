{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];
  hardware.intelgpu.vaapiDriver = "intel-media-driver";
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;


  services.upower = {
    enable = true;
    percentageCritical = 15;
    percentageAction = 10;
    criticalPowerAction = "PowerOff";
  };


  ######################## BOOT ########################

  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.extraModulePackages = with config.boot.kernelPackages; [ qc71_slimbook_laptop ];
  boot.kernelModules = [ "qc71_laptop" ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.timeout = lib.mkForce 2;

  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    memtest86.enable = true;
    configurationLimit = 8;
  };

  boot.kernel.sysctl."kernel.sysrq" = 1;
  boot.kernelParams = [ ];

  ######################## NVIDIA ########################

  services.switcherooControl.enable = true;
  hardware.nvidia = {
    primeBatterySaverSpecialisation = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.beta;
    open = true;
  };

  ######################## HDMI ########################

  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.ddcutil ];
  # Turn on external monitor:
  # ddcutil setvcp D6 0x01
  # Turn off external monitor:
  # ddcutil setvcp D6 0x05

  ######################## FILESYSTEMS ########################

  fileSystems."/" = {
    options = [
      "relatime"
      "lazytime"
    ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/884ae108-21f0-4683-ad71-a39ccd45e910";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "noatime" ];
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/nix" ];
    interval = "monthly";
  };
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/0cf1fffe-2c1f-4c9a-b29b-5d63d22dd602";
    fsType = "ext4";
    options = [
      "nofail"
      "noatime"
    ];
  };
  fileSystems."/home/lucasfa/games" = {
    mountPoint = "/home/lucasfa/games";
    device = "/mnt/data/games";
    options = [
      "bind"
      "noatime"
    ];
  };
}
