{
  lib,
  config,
  pkgs,
  ...
}:
{

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
  ];
}
