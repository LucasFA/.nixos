{
  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # use the following for unstable:
    # nixpkgs.url = "nixpkgs/nixos-unstable";

    # or any branch you want:
    # nixpkgs.url = "nixpkgs/{BRANCH-NAME}";
  };

  outputs = { self, nixpkgs, home-manager,  ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
	  inherit system;
          modules = [ ./configuration.nix ];
      };
    };
      homeConfigurations = {
	lucasfa = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
	  modules = [ ./home.nix ];
	};
      };
  };
}