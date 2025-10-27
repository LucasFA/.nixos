{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fuzzel
    waybar
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    kitty
    swaybg
    swayidle
    swaylock-effects
    xwayland-satellite

    grim
    slurp
    swappy

    adw-gtk3
    gnome-themes-extra
    papirus-icon-theme
  ];

  systemd.user.services.mako = {
    enable = true;
    script = "${pkgs.mako}/bin/mako";
  };

  programs.niri.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  xdg.portal.config.common.default = [
    "gtk"
    "gnome"
  ];
}
