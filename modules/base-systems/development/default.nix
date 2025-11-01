{ pkgs, ... }:

{
  virtualisation = {
    docker.enable = true;
  };
  environment.systemPackages = with pkgs; [
    nixd
    distrobox
    licensee
    fd
    bat
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
