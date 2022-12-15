{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:rycee/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-config-extras.url = "git+ssh://git@github.com/voidcontext/nix-config-extras?ref=main";
    nix-config-extras.inputs.nixpkgs.follows = "nixpkgs";

    blog.url = "git+ssh://git@github.com/voidcontext/blog.gaborpihaj.com.git?ref=main";
    blog.inputs.nixpkgs.follows = "nixpkgs";

    blog-beta.url = "git+ssh://git@github.com/voidcontext/blog.gaborpihaj.com.git?ref=main";
    blog-beta.inputs.nixpkgs.follows = "nixpkgs";

    rnix-lsp.url = "github:nix-community/rnix-lsp?ref=v0.2.5";
    # doesn't work with 22.11, produces: error: nixVersions.nix_2_4 has been removed
    # rnix-lsp.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";
    
    indieweb-tools.url = "github:voidcontext/indieweb-tools";
    indieweb-tools.inputs.nixpkgs.follows = "nixpkgs";
    
    mqtt2influxdb2.url = "github:voidcontext/mqtt2influxdb2-rs";
    mqtt2influxdb2.inputs.nixpkgs.follows = "nixpkgs";
    };

  outputs = { self, darwin, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let

      localLib = import ./lib;

      weechatOverlay = self: super:
        {
          # TODO: fix in 22.11
          # weechat = super.weechat.override {
          #   configure = { availablePlugins, ... }: {
          #     scripts = with super.weechatScripts; [
          #       weechat-matrix
          #     ];
          #   };
          # };
        };

      overlays = [ weechatOverlay ];
      
      sysDefaults = system: {
        inherit nixpkgs nixpkgs-unstable overlays system;
      };

      x86_64-darwin = localLib.mkSys (sysDefaults "x86_64-darwin");

      x86_64-linux = localLib.mkSys (sysDefaults "x86_64-linux");

      aarch64-linux = localLib.mkSys (sysDefaults "aarch64-linux");

      mkHelix = system: {
        package = inputs.helix.packages.${system}.default;
      };

      darwinDefaults = rec {
        system = "x86_64-darwin";
        specialArgs = inputs // {
          inherit localLib;
          inherit (x86_64-darwin) pkgs pkgsUnstable;
          localPackages = import ./packages { inherit (x86_64-darwin) pkgs; };
          helix = mkHelix system;
        };
      };

      defaultSystemModules = [
        ./modules/system/base
        ({ config, pkgsUnstable, localPackages, helix, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            ./modules/home/base
            ./modules/home/development/java
            ./modules/home/development/scala
            ./modules/home/programs/kitty
            ./modules/home/virtualization/lima
          ];
          home-manager.extraSpecialArgs = {
            inherit localLib pkgsUnstable localPackages inputs helix;
            systemConfig = config;
          };
        })
      ];

      defaultDarwinSystemModules = defaultSystemModules ++ [
        home-manager.darwinModules.home-manager
      ];

      defaultNixosSystemModules = defaultSystemModules ++ [
        home-manager.nixosModules.home-manager
      ];

    in
    {

      apps.x86_64-darwin.rebuild = {
        type = "app";
        program = "${localLib.mkRebuildDarwin x86_64-darwin.pkgs}/bin/rebuild";
      };

      apps.aarch64-linux.rebuild = {
        type = "app";
        program = "${localLib.mkRebuildNixos aarch64-linux.pkgs}/bin/rebuild";
      };

      apps.x86_64-linux.rebuild = {
        type = "app";
        program = "${localLib.mkRebuildNixos x86_64-linux.pkgs}/bin/rebuild";
      };

      darwinConfigurations = {
        "Sagittarius-A" = darwin.lib.darwinSystem (
          darwinDefaults //
          {
            modules =
              defaultDarwinSystemModules ++
              [ ./hosts/Sagittarius-A/configuration.nix ];
          }
        );

        work = darwin.lib.darwinSystem (
          darwinDefaults //
          {
            modules =
              defaultDarwinSystemModules ++
              [ ./hosts/work/configuration.nix ];
          }
        );
      };

      nixosConfigurations = {

        # NixOS VM @ DO
        deneb = nixpkgs.lib.nixosSystem {
          inherit (x86_64-linux) system;
          specialArgs = inputs // { inherit (x86_64-linux) pkgs pkgsUnstable; 
            helix = mkHelix "x86_64-linux"; 
            secrets = inputs.nix-config-extras.secrets;
          };
          modules = defaultNixosSystemModules ++ [ ./hosts/deneb/configuration.nix ];
        };

        # NixOS on a RaspberryPi 4 model B
        electra = nixpkgs.lib.nixosSystem {
          inherit (aarch64-linux) system;
          specialArgs = inputs // { 
            inherit inputs;
            inherit (aarch64-linux) pkgs pkgsUnstable; 
            helix = mkHelix "aarch64-linux"; 
            secrets = inputs.nix-config-extras.secrets;
          };
          modules = defaultNixosSystemModules ++ [ ./hosts/electra/configuration.nix ];
        };
      };

      devShells.x86_64-darwin.default =
        with x86_64-darwin; pkgs.mkShell {
          buildInputs = [
            pkgs.nixpkgs-fmt
            inputs.rnix-lsp.packages.x86_64-darwin.rnix-lsp
          ];
        };
    };
}

