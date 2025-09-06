{ lib, self, ... }:
{
  # networking.networkmanager.enable = lib.mkForce false;
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  imports = [
    (self.outPath + "/modules/core/nixpkgs.nix")
    (self.outPath + "/modules/core/nix.nix")
    (self.outPath + "/modules/core/networking.nix")
    (self.outPath + "/modules/core/shells.nix")
    (self.outPath + "/modules/core/user")
    (self.outPath + "/modules/base-systems/server/ssh.nix")
  ];
  networking.networkmanager.enable = lib.mkForce false;
}
