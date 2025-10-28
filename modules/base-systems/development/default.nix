{ pkgs, ... }:

{
  virtualisation = {
    docker.enable = true;
  };
  environment.systemPackages = with pkgs; [
    nixd
    distrobox
    # compose2nix
    licensee
    fd
    bat
    zed-editor-fhs
    helix
    ghostty
    # Neovim deps
    cargo
    python3
    clang

    hugo
  ];
}
