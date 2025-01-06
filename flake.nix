{
  description = "My first flake!";

  inputs = {
    nixpkgs.url = "git+file:///home/lucasfa/dev/nixpkgs?ref=testing-nixos-24.11";
    #nixpkgs.url = "github:LucasFA/nixpkgs/testing-nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:LucasFA/nixos-hardware/slimbook_hero";
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

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      nixosConfigurations = {
        slimbook = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            nixos-hardware.nixosModules.slimbook-hero-rpl-rtx
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
