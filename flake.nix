{
  description = "My first flake!";

  inputs = {
    # llm-agents.url = "github:numtide/llm-agents.nix";
    nixpkgs-stable.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    autofirma-nix = {
      # url = "github:nix-community/autofirma-nix/release-24.11";
      url = "github:nix-community/autofirma-nix/develop";
      # url = "github:LucasFA/autofirma-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-unit.inputs.nixpkgs.follows = "nixpkgs";
    };
    lucasfa-nur = {
      url = "github:LucasFA/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:LucasFA/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
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
      microvm,
      systems,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./modules/treefmt/default.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./modules/treefmt);

      # Single source of truth for hosts. `role` also picks the channel
      # (servers on stable, desktop on unstable) and the srvos base profile.
      hosts = {
        slimbook = {
          dir = "slimbook-hero";
          role = "desktop";
          modules = [
            nixos-hardware.nixosModules.slimbook-hero-rpl-rtx
            srvos.nixosModules.mixins-systemd-boot
            lanzaboote.nixosModules.lanzaboote
            microvm.nixosModules.host
            autofirma-nix.nixosModules.default
          ];
          hmSharedModules = [ agenix.homeManagerModules.default ];
        };
        server-nuc1 = {
          dir = "nuc1";
          role = "server";
          modules = [
            nixos-hardware.nixosModules.intel-nuc-5i5ryb
            { srvos.boot.consoles = nixpkgs-stable.lib.mkDefault [ ]; }
          ];
        };
        server-hp-omen = {
          dir = "hp-omen";
          role = "server";
          modules = [
            nixos-hardware.nixosModules.omen-15-ce002ns
            srvos.nixosModules.mixins-systemd-boot
          ];
        };
        server-node804 = {
          dir = "node804";
          role = "server";
          modules = [ srvos.nixosModules.mixins-systemd-boot ];
        };
      };

      mkHost =
        {
          dir,
          role,
          modules ? [ ],
          hmSharedModules ? [ ],
        }:
        let
          isServer = role == "server";
          nixpkgs' = if isServer then nixpkgs-stable else nixpkgs;
          home-manager' = if isServer then home-manager-stable else home-manager;
        in
        nixpkgs'.lib.nixosSystem {
          specialArgs = {
            inherit inputs system self;
            hostRole = role;
          };
          modules = [
            ./hosts/${dir}
            agenix.nixosModules.default
            home-manager'.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = {
                  inherit self;
                  hostRole = role;
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.lucasfa = import ./hosts/${dir}/home.nix;
                sharedModules = hmSharedModules;
              };
            }
          ]
          ++ (
            if isServer then
              [
                srvos.nixosModules.common
                srvos.nixosModules.server
              ]
            else
              [ srvos.nixosModules.desktop ]
          )
          ++ modules;
        };
    in
    {
      nixosConfigurations = lib.mapAttrs (_: mkHost) hosts;
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
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });
    };
}
