{
  inputs,
  defaultOverlays,
  defaultConfig,
  defaultSystemModules,
  localLib,
  config-extras,
  ...
}: let
  inherit (inputs) nixpkgs darwin home-manager;
  system = "x86_64-darwin";
  pkgs = import nixpkgs {
    inherit system;
    overlays = defaultOverlays;
    config = defaultConfig;
  };
  darwinDefaults = {
    inherit pkgs system;
    specialArgs = {
      inherit localLib inputs config-extras;
      inherit (inputs) nixpkgs;
    };
  };
in {
  "Sagittarius-A" = darwin.lib.darwinSystem (
    darwinDefaults
    // {
      modules =
        defaultSystemModules
        ++ [
          home-manager.darwinModules.home-manager
          ./hosts/Sagittarius-A/configuration.nix
        ];
    }
  );
  "work" = darwin.lib.darwinSystem (
    darwinDefaults
    // {
      modules =
        defaultSystemModules
        ++ [
          home-manager.darwinModules.home-manager
          ./hosts/work/configuration.nix
        ];
    }
  );
}
