{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-oldstable.url = "nixpkgs/release-21.11";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:rycee/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    scala-mode.url = "github:Kazark/emacs-scala-mode?ref=scala3";
    scala-mode.flake = false;

    nix-config-extras.url = "git+ssh://git@github.com/voidcontext/nix-config-extras?commit=0468eda053d0d38c8521f9a249721ffda5dbc528";
    nix-config-extras.inputs.nixpkgs.follows = "nixpkgs";

    blog-beta.url = "git+ssh://git@github.com/voidcontext/blog.gaborpihaj.com.git?ref=main";
    blog-beta.inputs.nixpkgs.follows = "nixpkgs";

    rnix-lsp.url = "github:nix-community/rnix-lsp?ref=v0.2.5";
    rnix-lsp.inputs.nixpkgs.follows = "nixpkgs";
    
    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, nixpkgs-unstable, nixpkgs-oldstable, home-manager, emacs-overlay, ... }@inputs:
    let
      
      localLib = import ./lib;

      weechatOverlay = self: super:
        {
          weechat = super.weechat.override {
            configure = { availablePlugins, ... }: {
              scripts = with super.weechatScripts; [
                weechat-matrix
              ];
            };
          };
        };

      overlays = [ emacs-overlay.overlay weechatOverlay ];

      x86_64-darwin = localLib.mkSys {
        inherit nixpkgs nixpkgs-unstable nixpkgs-oldstable overlays;
        system = "x86_64-darwin";
      };

      x86_64-linux = localLib.mkSys {
        inherit nixpkgs nixpkgs-unstable nixpkgs-oldstable overlays;
        system = "x86_64-linux";
      };

      aarch64-linux = localLib.mkSys {
        inherit nixpkgs nixpkgs-unstable nixpkgs-oldstable overlays;
        system = "aarch64-linux";
      };

      mkHelix = system: {
        package = inputs.helix.packages.${system}.default;
      };

      darwinDefaults = rec {
        system = "x86_64-darwin";
        specialArgs = inputs // {
          inherit localLib;
          inherit (x86_64-darwin) pkgs pkgsUnstable pkgsOldStable;
          localPackages = import ./packages { inherit (x86_64-darwin) pkgs; };
          helix = mkHelix system;
        };
      };

      defaultSystemModules = [
        ./modules/system/base
        ({ config, pkgsUnstable, pkgsOldStable, localPackages, helix, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            ./modules/home/base
            ./modules/home/development/clojure
            ./modules/home/development/java
            ./modules/home/development/rust
            ./modules/home/development/scala
            ./modules/home/programs/kitty
            ./modules/home/virtualization/lima
          ];
          home-manager.extraSpecialArgs = {
            inherit localLib pkgsUnstable pkgsOldStable localPackages inputs helix;
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

      apps.x86-64-linux.rebuild = {
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
          specialArgs = inputs // { inherit (x86_64-linux) pkgs pkgsUnstable; helix = mkHelix "x86-64_linux";};
          modules = defaultNixosSystemModules ++ [ ./hosts/deneb/configuration.nix ];
        };

        # NixOS on a RaspberryPi 4 model B
        electra = nixpkgs.lib.nixosSystem {
          inherit (aarch64-linux) system;
          specialArgs = inputs // { inherit (aarch64-linux) pkgs pkgsUnstable; helix = mkHelix "aarch-64_linux"; };
          modules = defaultNixosSystemModules ++ [ ./hosts/electra/configuration.nix ];
        };
      };

      devShells.x86_64-darwin.default =
        with x86_64-darwin; pkgs.mkShell {
          buildInputs = [
            inputs.rnix-lsp.packages.x86_64-darwin.rnix-lsp
          ];
        };
    };
}

