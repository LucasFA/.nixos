{
  self,
  lib,
  ...
}:
{

  nix = {
    settings = {
      keep-outputs = true;
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
