# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/Console" = {
      font-scale = 1.9000000000000008;
      last-window-maximised = true;
    };

    "org/gnome/Extensions" = {
      window-maximized = true;
    };

    "org/gnome/Weather" = {
      window-maximized = true;
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = false;
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "terminate:ctrl_alt_bksp"
        "caps:swapescape"
        "lv3:switch"
      ];
    };

    "org/gnome/desktop/interface" = {
      clock-show-seconds = false;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      font-antialiasing = "grayscale";
      show-battery-percentage = true;
      text-scaling-factor = 1.25;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
      speed = 0.5338345864661653;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      speed = 0.6731517509727627;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
    };

    "org/gnome/desktop/search-providers" = {
      disabled = [
        "org.gnome.Characters.desktop"
        "org.gnome.seahorse.Application.desktop"
        "org.gnome.Software.desktop"
        "org.gnome.Calculator.desktop"
        "org.gnome.Contacts.desktop"
        "org.gnome.clocks.desktop"
      ];
      sort-order = [
        "org.gnome.Settings.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Contacts.desktop"
      ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/evince/default" = {
      continuous = true;
      dual-page = false;
      dual-page-odd-left = true;
      enable-spellchecking = true;
      fullscreen = true;
      inverted-colors = false;
      show-sidebar = false;
      sidebar-page = "thumbnails";
      sidebar-size = 132;
      sizing-mode = "free";
      window-ratio = mkTuple [
        0.9798657718120806
        0.7577197149643705
      ];
      zoom = 1.200811762484096;
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 1498;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/gnome-system-monitor" = {
      maximized = true;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
      workspaces-only-on-primary = true;
    };

    "org/gnome/nautilus/window-state" = {
      maximized = true;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = false;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [ ];
      enabled-extensions = [
        "caffeine@patapon.info"
        "gamemodeshellextension@trsnaqe.com"
      ];
      favorite-apps = [
        "firefox.desktop"
      ];
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/shell/extensions/caffeine" = {
      indicator-position-max = 2;
      show-indicator = "only-active";
    };

    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = [ ];
    };

    "org/gnome/shell/world-clocks" = {
      locations = [ ];
    };
  };
}
