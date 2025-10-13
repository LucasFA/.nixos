{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ../graphical
    ./torrent.nix
    ./printer.nix
  ];

  hardware.bluetooth.settings = {
    General = {
      # Experimental = true;
      Disable = "Handsfree";
    };
  };
  environment.systemPackages = with pkgs; [
    feishin
    spotify
    spotify-player
    telegram-desktop
    element-desktop
    signal-desktop
    discord
    rquickshare
    subsurface
    obsidian
    # jellyfin-media-player # reinstall when EOL qt5 resolved
  ];

  services = {
    flatpak.enable = true;
    tailscale.enable = true;
  };
  programs = {
    htop.enable = true;
    kdeconnect.enable = true;
    nix-ld.enable = true;
    autofirma = {
      enable = true;
      firefoxIntegration.enable = true; # Let Firefox use AutoFirma
    };
    configuradorfnmt = {
      enable = true;
      firefoxIntegration.enable = true;
    };
    firefox.policies.SecurityDevices = {
      "OpenSC PKCS#11" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
      "DNIeRemote" = "${config.programs.dnieremote.finalPackage}/lib/libdnieremotepkcs11.so";
    };
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 6400000;
    "net.core.wmem_max" = 6400000;
  };

  services = {
    syncthing = {
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
        #listenAddress = false;
      };
      settings.devices = {
        server-nuc1 = {
          id = "3Q24ZE2-QVV66XD-AVEDCYP-STB76EP-Q3AVWLJ-KS7PA2L-SMOOTGJ-SVYQPQ3";
        };
      };
      settings.folders = {
        "home/lucasfa/syncthing" = {
          label = "Server inbox";
          id = "server-inbox";
          devices = [ "server-nuc1" ];
          path = "~/syncthing";
        };
      };
    };
  };
}
