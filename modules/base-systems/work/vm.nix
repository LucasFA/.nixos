{
  pkgs,
  lib,
  config,
  ...
}:
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.lucasfa.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd = {
    # enable = lib.mkForce true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf = {
        enable = true;
        packages = [pkgs.OVMFFull.fd];
      };
      swtpm.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    quickemu
    socat
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    win-virtio
    win-spice
    adwaita-icon-theme
  ];

}
