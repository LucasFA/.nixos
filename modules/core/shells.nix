{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    vim
    fd
    ripgrep
    tealdeer
    nvd
  ];
  environment.shellAliases = {
    nixos-rbb = "nixos-rebuild build --flake . && nvd diff /run/current-system result";
    nixos-rbs = "nixos-rebuild switch --flake .";
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
  };
}
