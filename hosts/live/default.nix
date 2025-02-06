{ lib, ... }:
{
  networking.networkmanager.enable = lib.mkForce false;
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
