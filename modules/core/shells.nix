{ pkgs, ... }:
{

  environment.systemPackages =
    with pkgs;
    [
      git
      vim
      fd
      fzf
      ripgrep
      tealdeer
      nvd
    ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; [
        LazyVim
      ];
    };
  };
  programs.zoxide.enable = true;

  environment.shellAliases = {
    nixos-rbb = "nixos-rebuild build --flake . && nvd diff /run/current-system result";
    sunixos-rbs = "sudo nixos-rebuild switch --flake ~/.nixos";
    ".." = "cd ..";
    "..." = "cd ../..";
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
