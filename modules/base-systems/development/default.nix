{ pkgs, ... }:

{
  virtualisation = {
    docker.enable = true;
  };
  environment.systemPackages = with pkgs; [
    nixd
    nixfmt
    nixfmt-tree
    distrobox
    licensee
    fd
    bat
    uv
    jq
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
