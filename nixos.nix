{
  inputs,
  defaultOverlays,
  defaultConfig,
  defaultSystemModules,
  config-extras,
  ...
}: let
  inherit (inputs) nixpkgs home-manager flake-utils;
  systemDefaults = {
    specialArgs = {
      inherit inputs config-extras;
      inherit (inputs) nixpkgs nixos-hardware; # for nixos-uconsole
    };
  };
  nixpkgsConfig = {
    system,
    overlays ? [],
  }: {
    nixpkgs.system = system;
    nixpkgs.overlays = defaultOverlays ++ overlays;
    nixpkgs.config = defaultConfig;
  };
in {
  # NixOS VM @ DO
  deneb =
    nixpkgs.lib.nixosSystem
    (systemDefaults
      // {
        modules =
          [(nixpkgsConfig {system = flake-utils.lib.system.x86_64-linux;})]
          ++ defaultSystemModules
          ++ [
            ./modules/system/static-sites
            home-manager.nixosModules.home-manager
            ./hosts/deneb/configuration.nix
          ];
      });

  # NixOS @ Hetzner
  kraz =
    nixpkgs.lib.nixosSystem
    (systemDefaults
      // {
        modules =
          [
            (nixpkgsConfig {
              system = flake-utils.lib.system.x86_64-linux;
              overlays = [inputs.attic.overlays.default];
            })
          ]
          ++ defaultSystemModules
          ++ [
            inputs.attic.nixosModules.atticd
            home-manager.nixosModules.home-manager
            ./hosts/kraz/configuration.nix
          ];
      });

  # NixOS on a RaspberryPi 4 model B
  electra =
    nixpkgs.lib.nixosSystem
    (systemDefaults
      // {
        modules =
          [(nixpkgsConfig {system = flake-utils.lib.system.aarch64-linux;})]
          ++ defaultSystemModules
          ++ [
            home-manager.nixosModules.home-manager
            ./hosts/electra/configuration.nix
          ];
      });

  # Asus X550C laptop
  albeiro =
    nixpkgs.lib.nixosSystem
    (systemDefaults
      // {
        modules =
          [(nixpkgsConfig {system = flake-utils.lib.system.x86_64-linux;})]
          ++ defaultSystemModules
          ++ [
            home-manager.nixosModules.home-manager
            ./hosts/albeiro/configuration.nix
          ];
      });

  # ClocworkPi uConsole
  orkaria = nixpkgs.lib.nixosSystem (systemDefaults
    // {
      modules =
        [
          (nixpkgsConfig {
            system = flake-utils.lib.system.aarch64-linux;
            overlays = [
              (final: super: {
                makeModulesClosure = x:
                  super.makeModulesClosure (x // {allowMissing = true;});
              })
            ];
          })
        ]
        ++ defaultSystemModules
        ++ [
          inputs.nixos-uconsole.nixosModules.default
          inputs.nixos-uconsole.nixosModules."kernel-6.1-potatomania-cross-build"
          home-manager.nixosModules.home-manager
          ./hosts/orkaria/configuration.nix
        ];
    });
}
