# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "apps/seahorse/listing" = {
      keyrings-selected = [ "secret-service:///org/freedesktop/secrets/collection/login" ];
    };

    "apps/seahorse/windows/key-manager" = {
      height = 1346;
      width = 2560;
    };

    "org/freedesktop/folks" = {
      primary-store = "eds:01d5afa44d1712de0ac4197091f3dd8c0622f207";
    };

    "org/gnome/Connections" = {
      first-run = false;
    };

    "org/gnome/Console" = {
      font-scale = 1.9000000000000008;
      last-window-maximised = true;
      last-window-size = mkTuple [
        1212
        816
      ];
    };

    "org/gnome/Contacts" = {
      did-initial-setup = true;
      window-fullscreen = false;
      window-height = 600;
      window-maximized = true;
      window-width = 800;
    };

    "org/gnome/Extensions" = {
      window-maximized = true;
    };

    "org/gnome/Snapshot" = {
      is-maximized = true;
      show-composition-guidelines = false;
      window-height = 640;
      window-width = 800;
    };

    "org/gnome/Weather" = {
      window-height = 433;
      window-maximized = false;
      window-width = 1302;
    };

    "org/gnome/calculator" = {
      accuracy = 9;
      angle-units = "degrees";
      base = 10;
      button-mode = "basic";
      number-format = "automatic";
      show-thousands = false;
      show-zeroes = false;
      source-currency = "";
      source-units = "degree";
      target-currency = "";
      target-units = "radian";
      window-maximized = false;
      window-size = mkTuple [
        360
        640
      ];
      word-size = 64;
    };

    "org/gnome/control-center" = {
      last-panel = "bluetooth";
      window-state = mkTuple [
        980
        640
        true
      ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [
        "Utilities"
        "YaST"
        "Pardus"
      ];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [
        "gnome-abrt.desktop"
        "gnome-system-log.desktop"
        "nm-connection-editor.desktop"
        "org.gnome.baobab.desktop"
        "org.gnome.Connections.desktop"
        "org.gnome.DejaDup.desktop"
        "org.gnome.Dictionary.desktop"
        "org.gnome.DiskUtility.desktop"
        "org.gnome.Evince.desktop"
        "org.gnome.FileRoller.desktop"
        "org.gnome.fonts.desktop"
        "org.gnome.Loupe.desktop"
        "org.gnome.seahorse.Application.desktop"
        "org.gnome.tweaks.desktop"
        "org.gnome.Usage.desktop"
        "vinagre.desktop"
      ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = false;
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [
        (mkTuple [
          "xkb"
          "us"
        ])
      ];
      sources = [
        (mkTuple [
          "xkb"
          "us"
        ])
        (mkTuple [
          "xkb"
          "es"
        ])
      ];
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
      text-scaling-factor = 1.32;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [
        "org-gnome-console"
        "firefox"
        "gnome-power-panel"
        "org-gnome-settings"
        "org-gnome-software"
        "org-gnome-nautilus"
        "com-valvesoftware-steam"
        "spotify"
        "steam"
        "org-gnome-evince"
        "dev-zed-zed"
        "element-desktop"
        "com-usebottles-bottles"
        "org-qbittorrent-qbittorrent"
        "discord"
        "org-gnome-extensions"
        "org-gnome-evolution-alarm-notify"
      ];
    };

    "org/gnome/desktop/notifications/application/com-usebottles-bottles" = {
      application-id = "com.usebottles.bottles.desktop";
    };

    "org/gnome/desktop/notifications/application/com-valvesoftware-steam" = {
      application-id = "com.valvesoftware.Steam.desktop";
    };

    "org/gnome/desktop/notifications/application/dev-zed-zed" = {
      application-id = "dev.zed.Zed.desktop";
    };

    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };

    "org/gnome/desktop/notifications/application/element-desktop" = {
      application-id = "element-desktop.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-evince" = {
      application-id = "org.gnome.Evince.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-evolution-alarm-notify" = {
      application-id = "org.gnome.Evolution-alarm-notify.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-extensions" = {
      application-id = "org.gnome.Extensions.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-software" = {
      application-id = "org.gnome.Software.desktop";
    };

    "org/gnome/desktop/notifications/application/org-qbittorrent-qbittorrent" = {
      application-id = "org.qbittorrent.qBittorrent.desktop";
    };

    "org/gnome/desktop/notifications/application/spotify" = {
      application-id = "spotify.desktop";
    };

    "org/gnome/desktop/notifications/application/steam" = {
      application-id = "steam.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = false;
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
        "org.gnome.Contacts.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/desktop/sound" = {
      event-sounds = true;
      theme-name = "__custom";
    };

    "org/gnome/evince/default" = {
      continuous = true;
      dual-page = false;
      dual-page-odd-left = true;
      enable-spellchecking = true;
      fullscreen = false;
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

    "org/gnome/evolution-data-server/calendar" = {
      reminders-past = [
        "50c1407ab8e277b5705677d7b89cd6fc988fae6en89d18389759f9efa305e7032261d0db4dee0ff8dt20250113T114500n1736765100n1736768700n1736772300nBEGIN:VEVENTrnDTSTART;TZID=Atlantic/Canary:20250113T114500rnDTEND;TZID=Atlantic/Canary:20250113T124500rnDTSTAMP:20250113T094014ZrnUID:rn 6opm2d9mc8p64b9g6orj4b9kchhmcb9occpm4b9mcosjccb4cgr30o9pcc@google.comrnCREATED:20250103T131031ZrnX-LIC-ERROR;X-LIC-ERRORTYPE=VALUE-PARSE-ERROR:No value for DESCRIPTION rn property. Removing entire property:rnLAST-MODIFIED:20250113T094014ZrnX-LIC-ERROR;X-LIC-ERRORTYPE=VALUE-PARSE-ERROR:No value for LOCATION rn property. Removing entire property:rnSEQUENCE:1rnSTATUS:CONFIRMEDrnSUMMARY:Cita hospitenrnTRANSP:OPAQUErnX-EVOLUTION-CALDAV-ETAG:63872444414rnBEGIN:VALARMrnACTION:DISPLAYrnDESCRIPTION:This is an event reminderrnTRIGGER:-PT1HrnX-EVOLUTION-ALARM-UID:89d18389759f9efa305e7032261d0db4dee0ff8drnEND:VALARMrnBEGIN:VALARMrnACTION:DISPLAYrnDESCRIPTION:This is an event reminderrnTRIGGER:-P1DrnX-EVOLUTION-ALARM-UID:eab64c3309f6c63d3e44eb2753a89a84b6e18282rnEND:VALARMrnEND:VEVENTrn"
        "50c1407ab8e277b5705677d7b89cd6fc988fae6en9548233f711fded86dfde73b4cc3275d896e73a8t20250113T134500n1736689500n1736775900n1736779500nBEGIN:VEVENTrnDTSTART;TZID=Atlantic/Canary:20250113T134500rnDTEND;TZID=Atlantic/Canary:20250113T144500rnDTSTAMP:20250103T131031ZrnUID:rn 6opm2d9mc8p64b9g6orj4b9kchhmcb9occpm4b9mcosjccb4cgr30o9pcc@google.comrnCREATED:20250103T131031ZrnX-LIC-ERROR;X-LIC-ERRORTYPE=VALUE-PARSE-ERROR:No value for DESCRIPTION rn property. Removing entire property:rnLAST-MODIFIED:20250103T131031ZrnX-LIC-ERROR;X-LIC-ERRORTYPE=VALUE-PARSE-ERROR:No value for LOCATION rn property. Removing entire property:rnSEQUENCE:0rnSTATUS:CONFIRMEDrnSUMMARY:Cita hospitenrnTRANSP:OPAQUErnX-EVOLUTION-CALDAV-ETAG:63871593031rnBEGIN:VALARMrnACTION:DISPLAYrnDESCRIPTION:This is an event reminderrnTRIGGER:-PT1HrnX-EVOLUTION-ALARM-UID:89ac0a3bb91046567e8c47f426ea76b0fd3f04c6rnEND:VALARMrnBEGIN:VALARMrnACTION:DISPLAYrnDESCRIPTION:This is an event reminderrnTRIGGER:-P1DrnX-EVOLUTION-ALARM-UID:9548233f711fded86dfde73b4cc3275d896e73a8rnEND:VALARMrnEND:VEVENTrn"
        "50c1407ab8e277b5705677d7b89cd6fc988fae6en98b3ceb35f3c1aa9e1208fa0889cf6bb7f9d8e6bt20250108T121500n1736337900n1736338500n1736342100nBEGIN:VEVENTrnDTSTART;TZID=Atlantic/Canary:20250108T121500rnDTEND;TZID=Atlantic/Canary:20250108T131500rnDTSTAMP:20241228T111817ZrnUID:rn 6dh3ap9gcksjcb9lckqm4b9k6kp32b9p68r66b9jcgp38p9p6dhjic9oc8@google.comrnCREATED:20241228T111817ZrnX-LIC-ERROR;X-LIC-ERRORTYPE=VALUE-PARSE-ERROR:No value for DESCRIPTION rn property. Removing entire property:rnLAST-MODIFIED:20241228T111817ZrnX-LIC-ERROR;X-LIC-ERRORTYPE=VALUE-PARSE-ERROR:No value for LOCATION rn property. Removing entire property:rnSEQUENCE:0rnSTATUS:CONFIRMEDrnSUMMARY:Cita salud centro CostarnTRANSP:OPAQUErnX-EVOLUTION-CALDAV-ETAG:63871067897rnBEGIN:VALARMrnACTION:DISPLAYrnDESCRIPTION:This is an event reminderrnTRIGGER:-PT10MrnX-EVOLUTION-ALARM-UID:98b3ceb35f3c1aa9e1208fa0889cf6bb7f9d8e6brnEND:VALARMrnEND:VEVENTrn"
      ];
    };

    "org/gnome/evolution" = {
      default-address-book = "01d5afa44d1712de0ac4197091f3dd8c0622f207";
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 1498;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 480;
      window-width = 600;
    };

    "org/gnome/gnome-system-monitor" = {
      current-tab = "processes";
      maximized = true;
      show-dependencies = false;
      show-whose-processes = "user";
    };

    "org/gnome/gnome-system-monitor/disktreenew" = {
      col-6-visible = true;
      col-6-width = 0;
    };

    "org/gnome/gnome-system-monitor/proctree" = {
      col-26-visible = false;
      col-26-width = 0;
      columns-order = [
        0
        12
        1
        2
        3
        4
        6
        7
        8
        9
        10
        11
        13
        14
        15
        16
        17
        18
        19
        20
        21
        22
        23
        24
        25
        26
      ];
      sort-col = 15;
      sort-order = 0;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
      workspaces-only-on-primary = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [
        890
        550
      ];
      initial-size-file-chooser = mkTuple [
        890
        550
      ];
      maximized = true;
    };

    "org/gnome/portal/filechooser/com/usebottles/bottles" = {
      last-folder-path = "/home/lucasfa/games/bottled/Horizon Forbidden West";
    };

    "org/gnome/portal/filechooser/com/valvesoftware/Steam" = {
      last-folder-path = "/mnt/data/games/steam";
    };

    "org/gnome/portal/filechooser/steam" = {
      last-folder-path = "/home/lucasfa/games/steam";
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
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
      ];
      last-selected-power-profile = "performance";
      welcome-dialog-last-shown-version = "46.2";
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

    "org/gnome/software" = {
      check-timestamp = mkInt64 1737027304;
      first-run = false;
      flatpak-purge-timestamp = mkInt64 1737030843;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
      window-size = mkTuple [
        857
        366
      ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 157;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [
        26
        23
      ];
      window-size = mkTuple [
        1231
        902
      ];
    };

  };
}
