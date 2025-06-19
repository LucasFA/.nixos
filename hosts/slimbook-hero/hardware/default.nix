{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./nvidia.nix
    ./filesystems.nix
    ./zram.nix
    ./power.nix
  ];
  hardware.intelgpu.vaapiDriver = "intel-media-driver";
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
  '';
}
