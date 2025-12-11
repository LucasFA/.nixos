{
  pkgs,
  lib,
  config,
  ...
}:
let
  virtEnabled = config.virtualisation.libvirtd.enable;
in
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = lib.mkIf virtEnabled true;
  users.users.lucasfa.extraGroups = lib.mkIf virtEnabled [ "libvirtd" ];

  environment.systemPackages =
    with pkgs;
    lib.mkIf virtEnabled [
      quickemu
      socat
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      adwaita-icon-theme
    ];

}
