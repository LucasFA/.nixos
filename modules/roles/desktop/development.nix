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

    environment.systemPackages = with pkgs; [
      nixd
      nixfmt
      nixfmt-tree
      distrobox
      licensee
      zed-editor-fhs
      helix
      ghostty
      rustup
      python3
      clang
      elan
      hugo
      pi-coding-agent
      opencode

      octaveFull
      ghostscript
      inkscape
      librsvg
      
      uv
      # quartz, cloudflare pages deployment of obsidian vault
      nodejs_22
      wrangler
    ];
  };
}
