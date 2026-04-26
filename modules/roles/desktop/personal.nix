{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.lfa.roles.desktop;
in
{
  config = lib.mkIf cfg.enable {
    services.printing = {
      drivers = with pkgs; [ hplipWithPlugin ];
    };

    hardware.bluetooth.settings = {
      General = {
        Experimental = true;
      };
    };

    services.flatpak.enable = true;
    services.tailscale.enable = true;
    programs.kdeconnect.enable = true;

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
        localAnnounceEnabled = true;
        globalAnnounceEnabled = false;
        natEnabled = true;
        minHomeDiskFree = {
          value = 5;
          unit = "%";
        };
      };
      settings.devices =
        let
          bothTcpQuic = ipPort: [
            "tcp://${ipPort}"
            "quic://${ipPort}"
          ];
        in
        {
          server-nuc1 = {
            id = "3Q24ZE2-QVV66XD-AVEDCYP-STB76EP-Q3AVWLJ-KS7PA2L-SMOOTGJ-SVYQPQ3";
            addresses =
              let
                IP = "100.109.201.11:22000";
              in
              bothTcpQuic IP;
          };
          phone = {
            id = "3BV6NRS-HRXZ7BI-SUZD7TW-W7AQW6D-ZLBRL37-QO2RPKP-FOYPXNL-OZ62HAT";
            addresses =
              let
                IP = "100.97.237.14";
              in
              bothTcpQuic IP;
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

    environment.systemPackages = with pkgs; [
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
    ];
  };
}
