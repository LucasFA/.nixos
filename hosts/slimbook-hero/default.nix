{
  pkgs,
  ...
}:

{
  imports = [
    "${
      builtins.fetchGit {
        url = "https://github.com/LucasFA/nixos-hardware.git";
        ref = "slimbook_hero";
        rev = "af392dd02020c0db28b23d8532f02f594708d202";
      }
    }/slimbook/hero/rpl_rtx"
    ./nvidia.nix
    ./filesystems.nix
    ./zram.nix
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.timeout = 2;
  boot.loader.grub = {
    enable = true;
    copyKernels = false; # no need: uses them straight from /nix/store
    configurationLimit = 25;
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
