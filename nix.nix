{
  self,
  ...
}:
{
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # remove channels, use flakes
    #registry.nixpkgs.flake = nixpkgs;
    #channel.enable = false;
    #settings.nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
  };
  # https://github.com/NixOS/nix/issues/9574 # part of removing channels
  #environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
    randomizedDelaySec = "30min";
    options = "--delete-older-than 30d --max-jobs 2";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "monthly" ];
  };

}
