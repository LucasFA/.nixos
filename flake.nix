{
  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:LucasFA/nixos-hardware/slimbook_hero";
    nixpkgs-lucasfa.url = "github:LucasFA/nixpkgs/nixos-24.11";
    my-nur-packages = {
      url = "github:LucasFA/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # use the following for unstable:
    # nixpkgs.url = "nixpkgs/nixos-unstable";

    # or any branch you want:
    # nixpkgs.url = "nixpkgs/{BRANCH-NAME}";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-lucasfa,
      home-manager,
      nixos-hardware,
      ...
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-lucasfa = nixpkgs-lucasfa.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            nixos-hardware.nixosModules.slimbook-hero-rpl-rtx
          ];
          #specialArgs = { 
            #pkgs-lucasfa = import pkgs-lucasfa { inherit system; };
          #};
        };
      };
      homeConfigurations = {
        lucasfa = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home ];
        };
      };
    };
}
