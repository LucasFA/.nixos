{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./user.nix
    ./nixpkgs.nix
    ./agenix
    ./hardening.nix
    ../roles/desktop
    ../roles/server
  ];

  options.lfa.hostRole = lib.mkOption {
    type = lib.types.enum [
      "desktop"
      "server"
    ];
    default = "desktop";
    description = "System role: desktop or server";
  };
  config = {
    lfa.roles.desktop.enable = config.lfa.hostRole == "desktop";
    lfa.roles.server.enable = config.lfa.hostRole == "server";
    services.thermald.enable = true;
    services.xserver = {
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

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

    services.locate.enable = true;
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

      # System utilities
      btrfs-progs
      dconf

      # Nix utils
      nix-output-monitor
      nixfmt

      # other utils
      dig
      dust
      trash-cli
      smartmontools
      cryptsetup
      bc
      # misc
      dmidecode
      lshw
    ];

    ################## fonts ############
    fonts.packages =
      with pkgs.nerd-fonts;
      [
        jetbrains-mono
        ubuntu
      ]
      ++ [
        pkgs.ubuntu-themes
        pkgs.ubuntu-sans
      ];

    ############### nix ###############

    # programs.nix-index.enable = true;
    programs.command-not-found.enable = false;
    programs.nh = {
      enable = true;
      clean.enable = lib.mkDefault false;
      clean.dates = lib.mkDefault "monthly";
      clean.extraArgs = lib.mkDefault "--keep-since 7d --keep 10";
      flake = lib.mkDefault "/home/lucasfa/.nixos";
    };
    nix = {
      settings = {
        # See https://github.com/NixOS/nix/issues/11728
        download-buffer-size = 4 * 67108864; # 64 MiB, the default, * 4 = 256
        extra-substituters = [
          # "https://cache.garnix.io"
          # "https://nix-community.cachix.org"
        ];
        extra-trusted-public-keys = [
          # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        trusted-users = [
          "root"
          "@wheel"
        ];
        allowed-users = [
          "root"
          "@wheel"
        ];
        # keep-outputs = false;
        # keep-derivations = true;
        experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
        ];
      };

      gc = {
        automatic = true;
        dates = "*-*-01 20:00:00";
        persistent = true;
        randomizedDelaySec = "30min";
        options = "--delete-older-than 14d --max-jobs 2";
      };
      optimise = {
        automatic = true;
        dates = [ "*-*-02 20:00:00" ];
      };
    };

    ################## networking ########################
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # Enable networking
    networking.networkmanager.enable = true;

    networking.firewall.enable = true;

    #age.secrets.wirelessconf.file = self.outPath + "/secrets/wireless.conf.age";
    #networking.wireless.secretsFile = "/run/agenix/wireless.conf";
    networking.wireless.networks = {
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
  };
}
