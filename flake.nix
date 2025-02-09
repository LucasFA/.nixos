{
  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:LucasFA/nixos-hardware";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    autofirma-nix = {
      url = "github:nix-community/autofirma-nix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-nur-packages = {
      url = "github:LucasFA/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # use the following for unstable:
    # nixpkgs.url = "nixpkgs/nixos-unstable";

    # or any branch you want:
    # nixpkgs.url = "nixpkgs/{BRANCH-NAME}";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      srvos,
      agenix,
      autofirma-nix,
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
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/slimbook-hero
            nixos-hardware.nixosModules.slimbook-hero-rpl-rtx
            srvos.nixosModules.common
            srvos.nixosModules.mixins-systemd-boot
            agenix.nixosModules.default
            autofirma-nix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.lucasfa = import ./home;
            }
          ];
        };
        server-hp-omen = lib.nixosSystem {
          specialArgs = { inherit inputs system; };
          modules = [
            ./hosts/hp-omen
            # /home/lucasfa/server/compose.nix
            nixos-hardware.nixosModules.omen-15-ce002ns
            srvos.nixosModules.common
            srvos.nixosModules.server
            srvos.nixosModules.mixins-systemd-boot
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.lucasfa = import ./home;
            }
          ];
        };
        live = nixpkgs.lib.nixosSystem {
          # build ISO with `nix build .#nixosConfigurations.live.config.system.build.isoImage`
          specialArgs = { inherit inputs system; };
          system = "x86_64-linux";
          modules = [
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./modules/core
            ./modules/base-systems/graphical
            agenix.nixosModules.default
            ./hosts/live
          ];
        };
      };
      homeConfigurations = {
        "lucasfa@slimbook" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home
            ./home/slimbook
          ];
        };
        "lucasfa@server-hp-omen" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home
            ./home/server-hp-omen
          ];
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
