{ pkgs, ... }:
{
  imports = [
    ./gnome
  ];

  services.desktopManager.gnome.enable = true;
  programs.hyprland.enable = true;

  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "lucasfa";
  services.displayManager.defaultSession = "gnome";

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    kitty # necessary for hyprland
    wl-clipboard
    gparted
  ];

  services.earlyoom.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true; # Yeah, no. Even using Wayland I need this. Just goes to TTY not an issue
}
