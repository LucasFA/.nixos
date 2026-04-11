{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.lfa.roles.desktop;
  patchedPkgs = import pkgs.path {
    inherit (pkgs) system config;
    overlays = [
      #(self: super: {
      #stdenv = super.stdenvAdapters.impureUseNativeOptimizations super.stdenv;
      #})
      (self: super: {
        rpcs3 = super.rpcs3.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            (super.fetchpatch {
              url = "https://github.com/LucasFA/rpcs3/commit/5046d08c55bbb693f438336cca00d92bb08a68d5.patch";
              sha256 = "sha256-HVbipN+vqQ8qAiKnNyMT8Mt1+J0CLziSHvyzEb2W7dQ=";
            })
          ];
        });
      })
    ];
  };
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
