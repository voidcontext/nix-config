{inputs}: let
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

  # --- Overlays ---
  packagesFromFlakesOverlay = final: prev: {
    deploy-rs-flake = defaultPackage inputs.deploy-rs final.system;
    indieweb-tools = defaultPackage inputs.indieweb-tools final.system;
    mqtt2influxdb2 = defaultPackage inputs.mqtt2influxdb2 final.system;
    felis = defaultPackage inputs.felis final.system;
    helixFlake = defaultPackage inputs.helix final.system;
    helix-steel = defaultPackage inputs.helix-steel final.system;
    helix-cogs = inputs.helix-steel.packages.${final.system}.helix-cogs;
    steel = inputs.steel.packages.${final.system}.steel;
  };
  unstableOverlay = final: prev: {
    unstable =
      if final.stdenv.isDarwin
      then let
        unstable = import inputs.nixpkgs-unstable {
          inherit (final) system config overlays;
        };
  # Patching nixpkgs as described at https://wiki.nixos.org/wiki/Nixpkgs/Patching_Nixpkgs, to fix kitty on macOS 15.1
        patched = unstable.applyPatches {
          name = "nixpkgs-patched";
          src = inputs.nixpkgs-unstable;
          patches = [
            (builtins.fetchurl {
              url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/352795.patch";
              sha256 = "sha256:1ngvs4qffymc79gf6rryakimnki3w0zsaf02j47bprlf95idcsx4";
            })
          ];
        };
      in
        import patched {
          inherit (final) system config overlays;
        }
      else
        import inputs.nixpkgs-unstable {
          inherit (final) system config overlays;
        };
  };
  localPackagesOverlay = final: prev: {
    vdx = let
      callPackage = final.lib.callPackageWith (final
        // {
          pkgs = final;
          mkBabashkaScript = callPackage ./lib/mkBabashkaScript.nix {};
          inherit callPackage;
        });
    in
      callPackage ./pkgs {};
  };
  scalaMetalsOverlay = final: prev: let
    # From: https://github.com/gvolpe/neovim-flake/blob/main/lib/metalsBuilder.nix
    version = "1.4.0";
    outputHash = "sha256-mmsCdv3zSwsaA00I5sQVy0V4fl1GytdgjVjs2r6x32Q=";
    metalsDeps = final.stdenv.mkDerivation {
      name = "metals-deps-${version}";
      buildCommand = ''
        export COURSIER_CACHE=$(pwd)
        ${final.coursier}/bin/cs fetch org.scalameta:metals_2.13:${version} \
          -r bintray:scalacenter/releases \
          -r sonatype:snapshots > deps
        mkdir -p $out/share/java
        cp -n $(< deps) $out/share/java/
      '';
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      inherit outputHash;
    };
  in {
    metals = prev.metals.overrideAttrs {
      inherit version;
      buildInputs = [metalsDeps];
    };
  };
in {
  defaultOverlays = [
    inputs.lamina.overlays.default
    packagesFromFlakesOverlay
    weechatOverlay
    localPackagesOverlay
    unstableOverlay
    scalaMetalsOverlay
  ];

  defaultConfig = {
    allowUnfreePredicate = pkg:
      builtins.elem (inputs.nixpkgs.lib.getName pkg) [
        "libretro-snes9x"
        "minecraft-launcher"
        "minecraft-server"
        "nvidia-settings"
        "nvidia-x11"
        "steam"
        "steam-original"
        "steam-run"
        "steam-runtime"
      ];
    nvidia.acceptLicense = true;
    # for seahub
    permittedInsecurePackages = [
      "python3.11-django-3.2.25"
    ];
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
            ./modules/home/development/clojure
            ./modules/home/development/java
            ./modules/home/development/nix
            ./modules/home/development/scala
            ./modules/home/programs/kitty
          ];
        home-manager.extraSpecialArgs = {
          inherit inputs;
          systemConfig = config;
        };
      })
    ];
}
