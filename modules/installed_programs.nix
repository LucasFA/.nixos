{ pkgs, ... }:

{
  imports = [
    ./base-systems/usage/personal 
    ./base-systems/usage/gaming
  ];

  services = {
    syncthing = {
      enable = true;
      dataDir = "/home/lucasfa/syncthing/";
      user = "lucasfa";
      group = "users";
      openDefaultPorts = true;
      guiAddress = "127.0.0.1:8384";
      overrideDevices = false; # These
      overrideFolders = false; # two settings permit imperative folder declaration
    };
  };

  environment.shellAliases = {
    nixos-rbb = "nixos-rebuild build --flake . && nvd diff /run/current-system result";
    nixos-rbs = "nixos-rebuild switch --flake .";
  };
  virtualisation = {
    docker.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Development
    vim
    tealdeer
    nvd
    nix-inspect
    nixfmt-rfc-style
    nixd
    nix-output-monitor
    distrobox

    # System utilities
    gparted
    btrfs-progs
    ventoy-full
    dconf
    wl-clipboard
    dmidecode
    lshw

  ];
}
