{
  pkgs,
  lib,
  ...
}:
# Machine-agnostic base: shell, CLI tools, nix settings and locale.
# Imported by every host (via ../core) and by the agent microVMs.
{
  ################## shell  #####################
  programs.zoxide.enable = true;
  environment.shellAliases = {
    nixos-rbb = "nixos-rebuild build --flake . && nvd diff /run/current-system result";
    sunixos-rbs = "nixos-rebuild switch --flake ~/.nixos --sudo";
    ".." = "cd ..";
    "..." = "cd ../..";
  };

  programs = {
    fish.enable = true;
    bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    # Terminal basics
    git
    vim
    fd
    fzf
    ripgrep
    tealdeer
    nvd

    # Development
    nix-inspect

    # Nix utils
    nix-output-monitor
    nixfmt

    # so ssh from ghostty (TERM=xterm-ghostty) works on every host and VM
    ghostty.terminfo

    # other utils
    dig
    dust
    trash-cli
    bc
    tmux
  ];

  ############### nix ###############
  nix.settings = {
    # See https://github.com/NixOS/nix/issues/11728
    download-buffer-size = 4 * 67108864; # this 64 MiB (the default) * 4 = 256
    trusted-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      # "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];

    # keep-outputs = false;
    keep-derivations = true;

    use-cgroups = true;
    use-xdg-base-directories = true;
    # auto-allocate-uids = true;
    experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
      "blake3-hashes"
      "cgroups"
      # "auto-allocate-uids"
    ];
  };

  ################## locale ##################
  time.timeZone = lib.mkOverride 900 "Atlantic/Canary"; # Higher preference than lib.MkDefault

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_MESSAGES = "en_US.UTF-8";
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };
}
