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
        darwin = {
          system = "x86_64-darwin";
          pkgs = import nixpkgs {
            system = darwin.system;
            overlays = [ emacs-overlay.overlay ];
          };
          jdk = darwin.pkgs.openjdk11_headless;
          localPackages = import ./packages {
            pkgs = darwin.pkgs;
          };
        };
      in
      {
        work = home-manager.lib.homeManagerConfiguration (with darwin; {
          inherit pkgs system;
          configuration = ./hosts/work.nix;
          homeDirectory = /Users/gaborpihaj;
          extraModules = [
            ./modules/common
            ./modules/emacs
            ./modules/scala
          ];
          username = "gaborpihaj";
          extraSpecialArgs = {
            inherit nixpkgs jdk localPackages;
            hdpi = true;
            nixConfigFlakeDir = "$HOME/workspace/personal/nix-config";
          };
        });
        "Sagittarius-A*" = home-manager.lib.homeManagerConfiguration (with darwin; {
          inherit pkgs system;
          configuration = ./hosts/Sagittarius-A.nix;
          homeDirectory = /Users/gaborpihaj;
          extraModules = [
            ./modules/common
            ./modules/emacs
            ./modules/scala
            ./modules/clojure
            ./modules/rust
          ];
          username = "gaborpihaj";
          extraSpecialArgs = {
            inherit nixpkgs jdk localPackages;
            hdpi = true;
            nixConfigFlakeDir = "$HOME/workspace/personal/nix-config";
          };
        });
      };
  };
}
