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
  environment.systemPackages = with pkgs; [
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
