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
    element-desktop
    qbittorrent
    discord
    telegram-desktop
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
}
