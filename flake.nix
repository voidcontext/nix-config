{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-21.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:rycee/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";

    # add github access token in ~/.config/nix/nix.con
    # access-tokens = github.com=ghp_...
    nix-config-extras.url = "github:voidcontext/nix-config-extras/1cec1e818dbb6b1d8052b63c14f4eadc76c60738";
    nix-config-extras.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, emacs-overlay, ... }@inputs:
    let
      lib = import ./lib;

      overlays = [ emacs-overlay.overlay ];

      darwin = lib.mkSys {
        inherit nixpkgs nixpkgs-unstable overlays;
        system = "x86_64-darwin";
      };

      linux_x86-64 = lib.mkSys {
        inherit nixpkgs nixpkgs-unstable overlays;
        system = "x86_64-linux";
      };

      mkDarwinHome = lib.mkSystemHome {
        inherit nixpkgs home-manager;
        sys = darwin;
        defaultModules = [
          ./modules/common
          ./modules/emacs
          ./modules/emacs-gui
        ];
      };

    in
    rec {
      # Standalone home manager configs, these are for users on not NixOS machines (mainly macos)
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
      };

      nixosConfigurations = {

        # NixOS VM @ DO
        deneb = nixpkgs.lib.nixosSystem {
          inherit (linux_x86-64) system;
          specialArgs = inputs // { inherit (linux_x86-64) pkgs pkgsUnstable; };
          modules = [ ./hosts/deneb/configuration.nix ];
        };

        # NixOS on a RaspberryPi 4 model B
        #elecra = nixpkgs.lib.nixosSystem { };

      };
    };
}
