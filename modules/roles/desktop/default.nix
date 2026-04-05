{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./graphical.nix
  ];

  options.lfa.roles.desktop.enable =
    lib.mkEnableOption "desktop role (graphical + personal + gaming + development tools)";

  config = lib.mkIf config.lfa.roles.desktop.enable {
    # Graphical (GNOME, sound, browsers, etc.) is imported above

    # Personal
    services.printing = {
      drivers = with pkgs; [ hplipWithPlugin ];
    };
    programs.nix-ld.enable = true;

    hardware.bluetooth.settings = {
      General = {
        Experimental = true;
      };
    };

    services.flatpak.enable = true;
    services.tailscale.enable = true;

    programs.htop.enable = true;
    programs.kdeconnect.enable = true;

    boot.kernel.sysctl = {
      "net.core.rmem_max" = 6400000;
      "net.core.wmem_max" = 6400000;
    };

    services.syncthing = {
      enable = true;
      dataDir = "/home/lucasfa";
      user = "lucasfa";
      group = "users";
      openDefaultPorts = true;
      guiAddress = "127.0.0.1:8384";
      settings.options = {
        urAccepted = 3;
        relaysEnabled = false;
        localAnnounceEnabled = false;
        globalAnnounceEnabled = false;
        natEnabled = false;
        minHomeDiskFree = 5;
      };
      settings.devices = {
        server-nuc1 = {
          id = "3Q24ZE2-QVV66XD-AVEDCYP-STB76EP-Q3AVWLJ-KS7PA2L-SMOOTGJ-SVYQPQ3";
          addresses = "tcp://100.109.201.11:22000";
        };
        phone = {
          id = "3BV6NRS-HRXZ7BI-SUZD7TW-W7AQW6D-ZLBRL37-QO2RPKP-FOYPXNL-OZ62HAT";
          addresses = "tcp://100.97.237.13:22000";
        };
      };
      settings.folders = {
        "home/lucasfa/syncthing" = {
          label = "Server inbox";
          id = "server-inbox";
          devices = [ "server-nuc1" ];
          path = "~/syncthing";
        };
        "home/lucasfa/Documents" = {
          label = "Documents";
          id = "documents";
          devices = [ "server-nuc1" ];
          path = "~/Documents";
          type = "sendonly";
        };
        "home/lucasfa/obsidian" = {
          label = "Obsidian vault";
          id = "obsidian-vault";
          devices = [
            "server-nuc1"
            "phone"
          ];
          path = "~/obsidian";
        };
      };
    };

    # Gaming
    boot.kernelModules = [ "ntsync" ];

    programs.steam = {
      enable = true;
      gamescopeSession.enable = false;
      localNetworkGameTransfers.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            libXcursor
            libXi
            libXinerama
            libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
      };
    };
    programs.gamemode.enable = true;
    programs.gamescope = {
      enable = false;
      capSysNice = true;
    };

    # Development
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      octave
      proton-vpn
      spotify
      telegram-desktop
      element-desktop
      signal-desktop
      discord
      subsurface
      obsidian
      jellyfin-media-player
      unrar
      protonup-qt
      pcsx2
      ckan
      nixd
      nixfmt
      nixfmt-tree
      distrobox
      licensee
      fd
      bat
      uv
      jq
      zed-editor-fhs
      helix
      ghostty
      rustup
      python3
      clang
      elan
      hugo
    ];
  };
}
