{
  self,
  # config,
  # pkgs,
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
  };
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

  # nix = {
  #registry.nixpkgs.flake = pkgs;
  #settings = {
  # nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
  #};
  # };
  # environment.etc."nix/inputs/nixpkgs".source = "${pkgs}";
}
