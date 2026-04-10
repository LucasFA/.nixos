{pkgs, lib, config, ...}:
let
  cfg = config.lfa.roles.desktop;
in
{
  imports = [
    ./sound.nix
    ./gnome
  ];

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;
    programs.hyprland = {
      enable = false;
      withUWSM = true;
      xwayland.enable = true;
    };

    services.displayManager.autoLogin.enable = false;
    services.displayManager.autoLogin.user = "lucasfa";
    services.displayManager.defaultSession = "gnome";

    programs.firefox.enable = true;
    programs.chromium.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      gparted
      chromium
      libreoffice-qt
    ];

    services.earlyoom.enable = true;
  };
}
