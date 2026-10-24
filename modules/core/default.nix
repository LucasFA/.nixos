{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./base.nix
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

    services.locate.enable = true;
    environment.systemPackages = with pkgs; [
      # System utilities
      btrfs-progs
      smartmontools
      cryptsetup
      # misc
      dmidecode
      lshw
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
        trusted-users = [
          "root"
          "@wheel"
        ];
        allowed-users = [
          "root"
          "@wheel"
        ];
      };

      gc = {
        automatic = true;
        dates = "*-*-01 20:00:00";
        persistent = true;
        randomizedDelaySec = "30min";
        options = "--delete-older-than 14d";
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
  };
}
