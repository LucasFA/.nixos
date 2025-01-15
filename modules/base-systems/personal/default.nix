{ pkgs, ... }:

{
  services = {
    flatpak.enable = true;
    tailscale.enable = true;
  };
  programs = {
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
  };
  environment.systemPackages = with pkgs; [
    telegram-desktop
    element-desktop
    signal-desktop
    qbittorrent
    discord
  ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true; # Yeah, no. Even using Wayland I need this. Just goes to TTY not an issue
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucasfa = {
    isNormalUser = true;
    description = "Lucas";
    extraGroups = [
      "networkmanager"
      "wheel"
    ] ++ 
      lib.optional config.virtualisation.docker.enable "docker";
  };

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
}
