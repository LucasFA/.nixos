{ pkgs, ... }:

{
  virtualisation = {
    docker.enable = true;
  };
  environment.systemPackages = with pkgs; [
    nixd
    nixfmt-rfc-style
    nixfmt-tree
    distrobox
    licensee
    fd
    bat
    uv
    zed-editor-fhs
    helix
    ghostty
    # Neovim deps
    rustup
    python3
    clang

    hugo
  ];
}
