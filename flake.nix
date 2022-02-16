{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-21.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:rycee/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, home-manager, emacs-overlay, ... }@inputs:
    let
      lib = import ./lib;

      overlays = [ emacs-overlay.overlay ];

      darwin = lib.mkSys {
        inherit nixpkgs overlays;
        system = "x86_64-darwin";
      };

      linux64 = lib.mkSys {
        inherit nixpkgs overlays;
        system = "x86_64-linux";
      };

      mkDarwinHome = lib.mkSystemHome {
        inherit nixpkgs home-manager;
        sys = darwin;
        defaultModules = [
          ./modules/common
          ./modules/emacs
        ];
      };

      mkLinuxHome = lib.mkSystemHome {
        inherit nixpkgs home-manager;
        sys = linux64;
        defaultModules = [
          ./modules/common
          ./modules/emacs
        ];
      };
    in
    rec {
      # home manager configs
      homeConfigurations = {

        "gaborpihaj@work" = mkDarwinHome (pkgs: {
          username = "gaborpihaj";
          configuration = ./hosts/work.nix;
          jdk = pkgs.openjdk11_headless;
          extraModules = [
            ./modules/scala
          ];
          nixConfigFlakeDir = "$HOME/workspace/personal/nix-config";
        });

        "gaborpihaj@Sagittarius-A*" = mkDarwinHome (pkgs: {
          username = "gaborpihaj";
          configuration = ./hosts/Sagittarius-A.nix;
          jdk = pkgs.openjdk11_headless;
          extraModules = [
            ./modules/scala
            ./modules/clojure
            ./modules/rust
          ];
          nixConfigFlakeDir = "$HOME/workspace/personal/nix-config";
        });

        "vdx@deneb" = mkLinuxHome (pkgs: {
          username = "gaborpihaj";
          configuration = ./hosts/deneb/home-vdx.nix;
          jdk = pkgs.openjdk11_headless;
          nixConfigFlakeDir = "/opt/nix-config";
        });

      };

      nixosConfigurations = {

        # NixOS VM @ DO
        deneb = nixpkgs.lib.nixosSystem {
          inherit (linux64) system;
          specialArgs = inputs // {
            inherit (linux64) pkgs;
          };
          modules = [
            ./hosts/deneb/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.vdx = import ./hosts/deneb/home-vdx.nix;
            }
          ];
        };

        # NixOS on a RaspberryPi 4 model B
        elecra = nixpkgs.lib.nixosSystem { };

      };
    };
}

