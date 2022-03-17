{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-21.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:rycee/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";

    # add github access token in ~/.config/nix/nix.con
    # access-tokens = github.com=ghp_...
    nix-config-extras.url = "github:voidcontext/nix-config-extras/0468eda053d0d38c8521f9a249721ffda5dbc528";
    nix-config-extras.inputs.nixpkgs.follows = "nixpkgs";

    blog-beta.url = "github:voidcontext/blog.gaborpihaj.com";
    blog-beta.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, nixpkgs-unstable, home-manager, emacs-overlay, ... }@inputs:
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

      darwin_x86_64 = localLib.mkSys {
        inherit nixpkgs nixpkgs-unstable overlays;
        system = "x86_64-darwin";
      };

      linux_x86-64 = localLib.mkSys {
        inherit nixpkgs nixpkgs-unstable overlays;
        system = "x86_64-linux";
      };

      linux_arm64 = localLib.mkSys {
        inherit nixpkgs nixpkgs-unstable overlays;
        system = "aarch64-linux";
      };

      darwinDefaults = {
        system = "x86_64-darwin";
        specialArgs = inputs // {
          inherit localLib;
          inherit (darwin_x86_64) pkgs pkgsUnstable;
          localPackages = import ./packages { inherit (darwin_x86_64) pkgs; };
        };
      };

      defaultSystemModules = [
        ./modules/system/base
        ({ config, pkgsUnstable, localPackages, ... }: {
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
            inherit localLib pkgsUnstable localPackages;
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

      apps."${darwin_x86_64.system}".rebuild = {
        type = "app";
        program = "${localLib.mkRebuildDarwin darwin_x86_64.pkgs}/bin/rebuild";
      };

      apps."${linux_arm64.system}".rebuild = {
        type = "app";
        program = "${localLib.mkRebuildNixos linux_arm64.pkgs}/bin/rebuild";
      };

      apps."${linux_x86-64.system}".rebuild = {
        type = "app";
        program = "${localLib.mkRebuildNixos linux_x86-64.pkgs}/bin/rebuild";
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
          inherit (linux_x86-64) system;
          specialArgs = inputs // { inherit (linux_x86-64) pkgs pkgsUnstable; };
          modules = defaultNixosSystemModules ++ [ ./hosts/deneb/configuration.nix ];
        };

        # NixOS on a RaspberryPi 4 model B
        electra = nixpkgs.lib.nixosSystem {
          inherit (linux_arm64) system;
          specialArgs = inputs // { inherit (linux_arm64) pkgs pkgsUnstable; };
          modules = defaultNixosSystemModules ++ [ ./hosts/electra/configuration.nix ];
        };
      };
    };
}

