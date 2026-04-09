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

    environment.systemPackages = with pkgs; [
      protonup-qt
      pcsx2
      ckan
    ];
  };
}
