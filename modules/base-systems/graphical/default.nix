{ pkgs, ... }:
{
  imports = [
    ./gnome
  ];
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    gparted
    vlc
  ];
  services.earlyoom.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true; # Yeah, no. Even using Wayland I need this. Just goes to TTY not an issue
}
