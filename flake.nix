{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:rycee/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/9a763a7acc4cfbb8603bb0231fec3eda864f81c0";
    nixos-uconsole.url = "git+https://git.vdx.hu/voidcontext/nixos-uconsole.git";
    nixos-uconsole.inputs.nixpkgs.follows = "nixpkgs";
    nixos-uconsole.inputs.nixos-hardware.follows = "nixos-hardware";

    deploy-rs.url = "github:serokell/deploy-rs";

    helix.url = "github:helix-editor/helix";

    indieweb-tools.url = "github:voidcontext/indieweb-tools";

    mqtt2influxdb2.url = "github:voidcontext/mqtt2influxdb2-rs";

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.11";

    lamina.url = "git+https://git.vdx.hu/voidcontext/lamina-rs.git";
    felis.url = "git+https://git.vdx.hu/voidcontext/felis.git?ref=refs/tags/v0.1.0";

    kitty-everforest-themes.url = "github:ewal/kitty-everforest";
    kitty-everforest-themes.flake = false;

    kitty-gruvbox-themes.url = "github:wdomitrz/kitty-gruvbox-theme";
    kitty-gruvbox-themes.flake = false;

    attic.url = "github:zhaofengli/attic/e6bedf1869f382cfc51b69848d6e09d51585ead6";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    darwin,
    flake-utils,
    home-manager,
    deploy-rs,
    ...
  } @ inputs: let
    localLib = import ./lib;

    config-extras = import ./extras;

    defaults = import ./defaults.nix {inherit inputs localLib;};
  in
    {
      darwinConfigurations = import ./darwin.nix {
        inherit inputs localLib config-extras;
        inherit (defaults) defaultOverlays defaultConfig defaultSystemModules;
      };

      nixosConfigurations = import ./nixos.nix {
        inherit inputs localLib config-extras;
        inherit (defaults) defaultOverlays defaultConfig defaultSystemModules;
      };

      deploy.nodes = import ./deploy.nix {inherit inputs self;};

      packages.${flake-utils.lib.system.x86_64-linux}.cache-warmup = let
        pkgs = import nixpkgs {
          system = flake-utils.lib.system.x86_64-linux;
          overlays = defaults.defaultOverlays;
          config = defaults.defaultConfig;
        };
      in
        pkgs.symlinkJoin {
          name = "cache-warmup";
          paths = [
            pkgs.attic-client
            pkgs.lamina
            pkgs.deploy-rs-flake
            pkgs.indieweb-tools
          ];
        };

      packages.${flake-utils.lib.system.x86_64-darwin}.cache-warmup = let
        pkgs = import nixpkgs {
          system = flake-utils.lib.system.x86_64-darwin;
          overlays = defaults.defaultOverlays;
          config = defaults.defaultConfig;
        };
      in
        pkgs.symlinkJoin {
          name = "cache-warmup";
          paths = [
            pkgs.attic-client
            pkgs.helixFlake
            pkgs.lamina
            pkgs.felis
            pkgs.deploy-rs-flake
          ];
        };
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = defaults.defaultOverlays;
        config = defaults.defaultConfig;
      };
      callPackage = pkgs.lib.callPackageWith {inherit pkgs callPackage;};
      packages = callPackage ./pkgs {};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.alejandra
          pkgs.git-crypt
          packages.rebuild
          packages.unlock-extras
          packages.jj
          packages.deploy
        ];
      };
    }));
}
