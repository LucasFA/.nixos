{
  self,
  lib,
  ...
}:
{

  nix = {
    settings = {
      # See https://github.com/NixOS/nix/issues/11728
      download-buffer-size = 4 * 67108864; # 64 MiB, the default, * 4 = 256
      extra-substituters = [
        "https://cache.garnix.io"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];
      keep-outputs = false;
      keep-derivations = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
    };
    # registry.nixpkgs.flake = "nixpkgs";
    # srvos config disables channels. Reenable to fix DBI sqlite error on command-not-found
    # and then, as root, add the nixos-unstable channel (nix-channel --add https://...)
    # and then update it (nix-channel --update)
    # channel.enable = true;
    # https://github.com/NixOS/nix/issues/9574 # part of removing channels
    #environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";

    gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
      randomizedDelaySec = "30min";
      options = "--delete-older-than 14d --max-jobs 2";
    };
    optimise = {
      automatic = true;
      dates = [ "monthly" ];
    };
  };
}
