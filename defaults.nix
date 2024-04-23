{
  inputs,
  localLib,
}: let
  defaultPackage = flake: system: flake.packages.${system}.default;

  weechatOverlay = self: super: {
    # TODO: fix in 22.11
    # weechat = super.weechat.override {
    #   configure = { availablePlugins, ... }: {
    #     scripts = with super.weechatScripts; [
    #       weechat-matrix
    #     ];
    #   };
    # };
  };

  # idea from: https://ayats.org/blog/channels-to-flakes
  pin-system-nixpkgs = [
    # pin <nixpkgs> and <nixpkgs-unstable>
    {
      environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
      environment.etc."nix/inputs/nixpkgs-unstable".source = inputs.nixpkgs.outPath;
      nix.nixPath = ["nixpkgs=/etc/nix/inputs/nixpkgs" "nixpkgs-unstable=/etc/nix/inputs/nixpkgs-unstable"];
    }
    # pin nixpkgs and nixpkgs-unstable in registry
    {
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      nix.registry.nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
    }
  ];
  pin-home-manager-nixpkgs = [
    # pin <nixpkgs> and <nixpkgs-unstable>
    (args: {
      xdg.configFile."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
      xdg.configFile."nix/inputs/nixpkgs-unstable".source = inputs.nixpkgs-unstable.outPath;
      home.sessionVariables.NIX_PATH =
        "nixpkgs=${args.config.xdg.configHome}/nix/inputs/nixpkgs:"
        + "nixpkgs-unstable=${args.config.xdg.configHome}/nix/inputs/nixpkgs-unstable"
        + "$\{NIX_PATH:+:$NIX_PATH}";
    })
    # pin nixpkgs and nixpkgs-unstable in registry
    {
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      nix.registry.nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
    }
  ];
in {
  defaultOverlays = [
    (final: prev: {
      deploy-rs-flake = defaultPackage inputs.deploy-rs final.system;
      indieweb-tools = defaultPackage inputs.indieweb-tools final.system;
      mqtt2influxdb2 = defaultPackage inputs.mqtt2influxdb2 final.system;
      felis = defaultPackage inputs.felis final.system;
      helixFlake = defaultPackage inputs.helix final.system;
    })
    weechatOverlay
    inputs.lamina.overlays.default
    inputs.attic.overlays.default

    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final) system config overlays;
      };
    })
  ];

  defaultConfig = {
    allowUnfreePredicate = pkg:
      builtins.elem (inputs.nixpkgs.lib.getName pkg) [
        "steam"
        "steam-run"
        "steam-original"
        "steam-runtime"
        "nvidia-x11"
        "nvidia-settings"
        "minecraft-launcher"
        "minecraft-server"
      ];
    nvidia.acceptLicense = true;
  };

  defaultSystemModules =
    pin-system-nixpkgs
    ++ [
      ./modules/system/base
      ({config, ...}: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules =
          pin-home-manager-nixpkgs
          ++ [
            ./modules/home/base
            ./modules/home/development/java
            ./modules/home/development/nix
            ./modules/home/development/scala
            ./modules/home/programs/kitty
          ];
        home-manager.extraSpecialArgs = {
          inherit localLib inputs;
          systemConfig = config;
        };
      })
    ];
}
