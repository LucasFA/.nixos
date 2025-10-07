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
  programs.virt-manager.enable = lib.mkIf virtEnabled true;
  users.users.lucasfa.extraGroups = lib.mkIf virtEnabled [ "libvirtd" ];
  virtualisation.libvirtd = {
    enable = false;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
      swtpm.enable = true;
    };
  };
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
      win-virtio
      win-spice
      adwaita-icon-theme
    ];

}
