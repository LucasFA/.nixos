{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.lucasfa.extraGroups = lib.mkIf config.programs.gamemode.enable [ "gamemode" ];
  boot.kernelModules = [ "ntsync" ];

  programs = {
    steam = {
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
    gamemode.enable = true;
    gamescope = {
      enable = false;
      capSysNice = true;
    };
  };
  environment.systemPackages =
    with pkgs;
    [
      protonup-qt
      pcsx2
      ckan
    ]
    ++ [
      patchedPkgs.rpcs3
    ];
}
