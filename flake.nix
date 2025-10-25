{
  description = "My first flake!";

  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      # url = "github:nix-community/home-manager/release-25.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:LucasFA/nixos-hardware";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    autofirma-nix = {
      # url = "github:nix-community/autofirma-nix/release-24.11";
      url = "github:nix-community/autofirma-nix";
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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
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
      nixpkgs-stable,
      home-manager,
      home-manager-stable,
      nixos-hardware,
      srvos,
      lanzaboote,
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
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./modules/treefmt/default.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./modules/treefmt);
    in
    {
      nixosConfigurations = {
        slimbook = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs system self; };
          modules = [
            ./hosts/slimbook-hero
            nixos-hardware.nixosModules.slimbook-hero-rpl-rtx
            srvos.nixosModules.common
            srvos.nixosModules.mixins-systemd-boot
            agenix.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
            autofirma-nix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit self; };
                useGlobalPkgs = true;
                users.lucasfa = import ./home;
                sharedModules = [
                  inputs.agenix.homeManagerModules.default
                ];
              };
            }
          ];
        };
        server-nuc1 = nixpkgs-stable.lib.nixosSystem {
          specialArgs = { inherit inputs system self; };
          modules = [
            ./hosts/nuc1
            # /home/lucasfa/server/compose.nix
            nixos-hardware.nixosModules.intel-nuc-5i5ryb
            srvos.nixosModules.common
            srvos.nixosModules.server
            # srvos.nixosModules.mixins-systemd-boot
            agenix.nixosModules.default
            home-manager-stable.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.lucasfa = import ./home;
            }
          ];
        };
        server-hp-omen = nixpkgs-stable.lib.nixosSystem {
          specialArgs = { inherit inputs system self; };
          modules = [
            ./hosts/hp-omen
            # /home/lucasfa/server/compose.nix
            nixos-hardware.nixosModules.omen-15-ce002ns
            srvos.nixosModules.common
            srvos.nixosModules.server
            srvos.nixosModules.mixins-systemd-boot
            agenix.nixosModules.default
            home-manager-stable.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.lucasfa = import ./home;
            }
          ];
        };
        server-node804 = nixpkgs-stable.lib.nixosSystem {
          specialArgs = { inherit inputs system self; };
          modules = [
            ./hosts/node804
            # /home/lucasfa/server/compose.nix
            # nixos-hardware.nixosModules.omen-15-ce002ns
            srvos.nixosModules.common
            srvos.nixosModules.server
            srvos.nixosModules.mixins-systemd-boot
            agenix.nixosModules.default
            home-manager-stable.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.lucasfa = import ./home;
            }
          ];
        };
        # live = nixpkgs-stable.lib.nixosSystem {
        # # build ISO with `nix build .#nixosConfigurations.live.config.system.build.isoImage`
        # specialArgs = { inherit inputs system self; };
        # system = "x86_64-linux";
        # modules = [
        # (nixpkgs-stable + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
        # (nixpkgs-stable + "/nixos/modules/installer/cd-dvd/channel.nix")
        # ./hosts/live
        # agenix.nixosModules.default
        # ];
        # };
      };
      homeConfigurations = {
        # "lucasfa@slimbook" = home-manager.lib.homeManagerConfiguration {
        # inherit pkgs;
        # modules = [
        # ./home
        # ];
        # };
        # "lucasfa@server-hp-omen" = home-manager.lib.homeManagerConfiguration {
        # inherit pkgs;
        # modules = [
        # ./home
        # ];
        # };
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
