{ pkgs, ... }:

{
  virtualisation = {
    docker.enable = true;
  };
  environment.systemPackages = with pkgs; [
    nixd
    distrobox
    compose2nix
    licensee
    fd
    bat
  ];
}
