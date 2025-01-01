{
  config,
  pkgs,
  pkgs-lucasfa,
  ...
}:
let
  confLimit = 25;
  pkgs-lucasfa = import (pkgs.fetchFromGitHub{
        owner = "LucasFA";
        repo = "nixpkgs";
        ##ref = "lucasfa_fork";
        rev = "b39ea173481341a13c7ca08b807adc4107f99f42";
        hash = "sha256-45ED2m2BOxfCB7XOkULcTDlSw2lf1IYzyC9pUC4JWIU=";
        }) { inherit system; };
in
{
  boot = {
    kernelPackages = pkgs.wip.linuxPackages_6_6;
    extraModulePackages = with config.boot.kernelPackages; [ qc71_slimbook_laptop ];
  };
  nixpkgs.config = {
    packageOverrides = pkgs: {
      wip = pkgs-lucasfa { config = config.nixpkgs.config; };
    };
  };
  #pkgs.linuxKernel.packages.linux_6_6.qc71_laptop
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.timeout = 2;

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
