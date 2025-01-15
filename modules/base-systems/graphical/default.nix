{ pkgs, ... }:
{
  imports = [
    ./gnome
  ];
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    gparted
  ];
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true; # Yeah, no. Even using Wayland I need this. Just goes to TTY not an issue
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };
}
