{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-21.11";

    home-manager.url = "github:rycee/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager, emacs-overlay, ... }@inputs: {
    hmConfig =
      let
        overlay-unstable = final: prev: {
          unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};
        };

        darwin = {
          system = "x86_64-darwin";
          pkgs = import nixpkgs {
            system = darwin.system;
            overlays = [ overlay-unstable emacs-overlay.overlay ];
          };
          jdk = darwin.pkgs.openjdk11_headless;
        };
      in
      {
        work = home-manager.lib.homeManagerConfiguration (with darwin; {
          inherit pkgs system;
          configuration = ./hosts/work.nix;
          homeDirectory = /Users/gaborpihaj;
          extraModules = [
            ./modules/common.nix
            ./modules/emacs
            ./modules/scala
            ./modules/git
            ./modules/bin
          ];
          username = "gaborpihaj";
          extraSpecialArgs = { inherit nixpkgs jdk; hdpi = true;};
        });
      };
  };
}
