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
    virtualisation.docker.enable = true;
    programs.direnv.enable = true;

    environment.systemPackages = with pkgs; [
      # Nix
      nixd
      nixfmt
      nixfmt-tree

      distrobox
      licensee

      # editors
      zed-editor-fhs
      helix
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
