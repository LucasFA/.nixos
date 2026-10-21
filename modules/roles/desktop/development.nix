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
    # virtualisation.docker.enable = true;
    programs.direnv.enable = true;

    # Workaround: systemd >= 262 refuses ghostty's Type=notify-reload unit (it signals
    # READY before installing its SIGUSR2 handler), so D-Bus activation from GNOME
    # often fails. https://github.com/ghostty-org/ghostty/issues/14398 (fixed in 1.4.0)
    systemd.user.services."app-com.mitchellh.ghostty" = {
      overrideStrategy = "asDropin";
      enableDefaultPath = false; # don't clobber the session PATH inside terminals
      serviceConfig.Type = "dbus";
    };

    environment.systemPackages = with pkgs; [
      # Nix
      nixd
      nixfmt
      nixfmt-tree

      distrobox
      licensee

      # editors
      zed-editor-fhs
      # helix
      # terminals
      ghostty
      #
      # languages
      rustup
      python3
      clang
      elan
      hugo
      uv
      # LLMs AI
      pi-coding-agent
      opencode

      # octave in particular
      octaveFull
      ghostscript
      inkscape
      librsvg

      # quartz, cloudflare pages deployment of obsidian vault
      nodejs_22
      wrangler
    ];
  };
}
