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
        # Workaround (see TODO.md): when launched on the NVIDIA GPU (the
        # desktop entry's PrefersNonDefaultGPU) while it is runtime-suspended,
        # the SteamRT3 bootstrap races itself during the ~2s wake-up and exits
        # with "Steam is already running", no window. Wake it first: reading
        # the PCI config space (what lspci does) blocks until it's resumed;
        # it then stays up ~20s.
        # https://github.com/ValveSoftware/steam-for-linux/issues/13893
        extraPreBwrapCmds = ''
          if [ "''${__NV_PRIME_RENDER_OFFLOAD:-}" = 1 ]; then
            for dev in /sys/bus/pci/devices/*; do
              if [ "$(${pkgs.coreutils}/bin/cat "$dev/vendor" 2>/dev/null)" = 0x10de ]; then
                ${pkgs.coreutils}/bin/cat "$dev/config" >/dev/null 2>&1 || true
              fi
            done
            ${pkgs.coreutils}/bin/sleep 1
          fi
        '';
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
    users.users.lucasfa = {
      extraGroups = [ "gamemode" ];
    };

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
