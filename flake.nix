{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:rycee/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/9a763a7acc4cfbb8603bb0231fec3eda864f81c0";
    nixos-uconsole.url = "git+https://git.vdx.hu/voidcontext/nixos-uconsole.git";
    nixos-uconsole.inputs.nixpkgs.follows = "nixpkgs";
    nixos-uconsole.inputs.nixos-hardware.follows = "nixos-hardware";

    deploy-rs.url = "github:serokell/deploy-rs";

    helix.url = "github:helix-editor/helix";
    helix-steel.url = "github:mattwparas/helix/steel-event-system";
    mattwparas-helix-cogs.url = "github:mattwparas/helix-config";
    mattwparas-helix-cogs.flake = false;

    # helix-steel.url = "github:voidcontext/helix/steel";

    steel.url = "github:mattwparas/steel";
    steel.inputs.nixpkgs.follows = "nixpkgs";

    indieweb-tools.url = "github:voidcontext/indieweb-tools";

    mqtt2influxdb2.url = "git+https://git.vdx.hu/voidcontext/mqtt2influxdb2-rs.git?ref=refs/heads/main";

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";

    lamina.url = "git+https://git.vdx.hu/voidcontext/lamina-rs.git";
    felis.url = "git+https://git.vdx.hu/voidcontext/felis.git?ref=refs/heads/main";

    zsh-nix-shell.url = "github:chisui/zsh-nix-shell/v0.8.0";
    zsh-nix-shell.flake = false;

    zsh-window-title.url = "github:olets/zsh-window-title/v1.2.0";
    zsh-window-title.flake = false;

    kitty-everforest-themes.url = "github:ewal/kitty-everforest";
    kitty-everforest-themes.flake = false;

    kitty-gruvbox-themes.url = "github:wdomitrz/kitty-gruvbox-theme";
    kitty-gruvbox-themes.flake = false;
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
    config-extras = import ./extras;

    defaults = import ./defaults.nix {inherit inputs;};
  in
    {
      darwinConfigurations = import ./darwin.nix {
        inherit inputs config-extras;
        inherit (defaults) defaultOverlays defaultConfig defaultSystemModules;
      };

      nixosConfigurations = import ./nixos.nix {
        inherit inputs config-extras;
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
            pkgs.deploy-rs-flake
            pkgs.felis
            pkgs.indieweb-tools
            pkgs.lamina
          ];
        };

      packages.${flake-utils.lib.system.aarch64-linux}.cache-warmup = let
        pkgs = import nixpkgs {
          system = flake-utils.lib.system.aarch64-linux;
          overlays = defaults.defaultOverlays;
          config = defaults.defaultConfig;
        };
      in
        pkgs.symlinkJoin {
          name = "cache-warmup";
          paths = [
            pkgs.deploy-rs-flake
            pkgs.attic-client
            pkgs.felis
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
            pkgs.colima
            pkgs.deploy-rs-flake
            pkgs.felis
            pkgs.helix-cogs
            pkgs.helix-steel
            pkgs.lamina
            pkgs.metals
            pkgs.steel
            pkgs.unstable.kitty
          ];
        };
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = defaults.defaultOverlays;
        config = defaults.defaultConfig;
      };
      callPackage = pkgs.lib.callPackageWith (pkgs
        // {
          inherit pkgs callPackage;
          mkBabashkaScript = callPackage ./lib/mkBabashkaScript.nix {};
        });
      packages = callPackage ./pkgs {};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.alejandra
          pkgs.git-crypt
          packages.rebuild
          packages.config-extras
          packages.jj
          packages.deploy
        ];
      };

      devShells.forgejo-darwin = callPackage ./devenv/forgejo.nix {};
    }));
}
