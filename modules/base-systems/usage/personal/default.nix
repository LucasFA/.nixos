{ pkgs, ... }:

{
  services = {
    flatpak.enable = true;
    tailscale.enable = true;
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
  };
  environment.systemPackages = with pkgs; [
    element-desktop
    qbittorrent
    discord
    telegram-desktop
  ];
}
