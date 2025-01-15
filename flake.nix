{
  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:LucasFA/nixos-hardware";
    my-nur-packages = {
      url = "github:LucasFA/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # use the following for unstable:
    # nixpkgs.url = "nixpkgs/nixos-unstable";

    # or any branch you want:
    # nixpkgs.url = "nixpkgs/{BRANCH-NAME}";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      systems,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./modules/treefmt/default.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./modules/treefmt);
    in
    {
      nixosConfigurations = {
        slimbook = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/slimbook-hero
            nixos-hardware.nixosModules.slimbook-hero-rpl-rtx
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.lucasfa = import ./home;
            }
          ];
        };
        server-hp-omen = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/hp-omen
         ];
        };
      };
      homeConfigurations = {
        lucasfa = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home ];
        };
      };
      # formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
