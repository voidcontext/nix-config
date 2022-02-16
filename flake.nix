{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-21.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:rycee/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, home-manager, emacs-overlay, ... }@inputs: {
    hmConfig =
      let
        darwin = rec {
          system = "x86_64-darwin";
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ emacs-overlay.overlay ];
          };
        };

        lib = import ./lib;

        mkDarwinHome = lib.mkSystemHome {
          inherit nixpkgs home-manager;
          inherit (darwin) system pkgs;
          defaultModules = [
            ./modules/common
            ./modules/emacs
          ];
        };
      in
      {
        work = mkDarwinHome (pkgs: {
          username = "gaborpihaj";
          configuration = ./hosts/work.nix;
          jdk = pkgs.openjdk11_headless;
          extraModules = [
            ./modules/scala
          ];
          nixConfigFlakeDir = "$HOME/workspace/personal/nix-config";
        });
        "Sagittarius-A*" = mkDarwinHome (pkgs: {
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
  };
}
