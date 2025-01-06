{ pkgs, ... }:

{
  imports = [ ];

  services = {
    flatpak.enable = true;
    tailscale.enable = true;
    syncthing = {
      enable = true;
      dataDir = "/home/lucasfa/syncthing/";
      user = "lucasfa";
      group = "users";
      openDefaultPorts = true;
      guiAddress = "127.0.0.1:8384";
      overrideDevices = false;
      overrideFolders = false;
    };
  };

  programs = {
    firefox.enable = true;
    bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };
    fish.enable = true;
    htop.enable = true;
    steam.enable = true;
    gamemode.enable = true;
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
    # System utilities
    gparted
    btrfs-progs
    ventoy-full
    dconf
    wl-clipboard
    dmidecode
    lshw
    # User
    # element-web
    # element-web-unwrapped
    element-desktop
    qbittorrent
    discord
    telegram-desktop
  ];
}
