{
  pkgs,
  ...
}:
let 
  confLimit = 25;
in
{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.timeout = 2;

  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    memtest86.enable = true;
    configurationLimit = confLimit;
  };

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

  boot.kernelParams = [
  ];
}
