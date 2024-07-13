{
  inputs,
  defaultOverlays,
  defaultConfig,
  defaultSystemModules,
  localLib,
  config-extras,
  ...
}: let
  inherit (inputs) nixpkgs home-manager flake-utils;
  mkPkgs = {
    system,
    overlays ? [],
  }:
    import nixpkgs {
      inherit system;
      overlays = defaultOverlays ++ overlays;
      config = defaultConfig;
    };
  nixosDefaults = pkgs: {
    inherit pkgs;
    inherit (pkgs) system;
    specialArgs = {
      inherit localLib inputs config-extras;
      inherit (inputs) nixpkgs nixos-hardware; # for nixos-uconsole
    };
  };
in {
  # NixOS VM @ DO
  deneb = nixpkgs.lib.nixosSystem ((nixosDefaults (mkPkgs {system = flake-utils.lib.system.x86_64-linux;}))
    // {
      modules =
        defaultSystemModules
        ++ [
          ./modules/system/static-sites
          home-manager.nixosModules.home-manager
          ./hosts/deneb/configuration.nix
        ];
    });

  # NixOS @ Hetzner
  kraz = nixpkgs.lib.nixosSystem ((nixosDefaults (mkPkgs {
      system = flake-utils.lib.system.x86_64-linux;
      overlays = [inputs.attic.overlays.default];
    }))
    // {
      modules =
        defaultSystemModules
        ++ [
          inputs.attic.nixosModules.atticd
          home-manager.nixosModules.home-manager
          ./hosts/kraz/configuration.nix
        ];
    });

  # NixOS on a RaspberryPi 4 model B
  electra = nixpkgs.lib.nixosSystem ((nixosDefaults (mkPkgs {system = flake-utils.lib.system.aarch64-linux;}))
    // {
      modules =
        defaultSystemModules
        ++ [
          home-manager.nixosModules.home-manager
          ./hosts/electra/configuration.nix
        ];
    });

  # Asus X550C laptop
  albeiro = nixpkgs.lib.nixosSystem ((nixosDefaults (mkPkgs {system = flake-utils.lib.system.x86_64-linux;}))
    // {
      modules =
        defaultSystemModules
        ++ [
          home-manager.nixosModules.home-manager
          ./hosts/albeiro/configuration.nix
        ];
    });

  orkaria = nixpkgs.lib.nixosSystem ((nixosDefaults (mkPkgs {
      system = flake-utils.lib.system.aarch64-linux;
      overlays = [
        (final: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // {allowMissing = true;});
        })
      ];
    }))
    // {
      modules =
        defaultSystemModules
        ++ [
          inputs.nixos-uconsole.nixosModules.default
          inputs.nixos-uconsole.nixosModules."kernel-6.1-potatomania-cross-build"
          home-manager.nixosModules.home-manager
          ./hosts/orkaria/configuration.nix
        ];
    });
}
