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
    ./hdmi-disconnect
  ];
  hardware.intelgpu.vaapiDriver = "intel-media-driver";
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
}
