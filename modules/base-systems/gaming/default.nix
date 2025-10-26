{ lib, pkgs, ... }:

let
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
              name = "fix-build-qt-6.10.patch";
              url = "https://github.com/RPCS3/rpcs3/commit/038ee090b731bf63917371a3586c2f7d7cf4e585.patch";
              hash = "sha256-jTIxsheG9b9zp0JEeWQ73BunAXmEIg5tj4SrWBfdHy8=";
            })
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
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;

      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
            xorg.libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
      };
    };
    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };
  environment.systemPackages =
    with pkgs;
    [
      protonup-qt
      pcsx2
    ]
    ++ [
      # patchedPkgs.rpcs3
    ];
}
