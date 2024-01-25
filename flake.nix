{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:rycee/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";

    helix.url = "github:helix-editor/helix";

    indieweb-tools.url = "github:voidcontext/indieweb-tools";

    mqtt2influxdb2.url = "github:voidcontext/mqtt2influxdb2-rs";

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.11";

    lamina.url = "git+https://git.vdx.hu/voidcontext/lamina-rs.git";
    felis.url = "git+https://git.vdx.hu/voidcontext/felis.git?ref=refs/tags/v0.1.0";
    mapthat-backend.url = "git+ssh://gitea@git.vdx.hu:5422/mapthat/mapthat-backend.git";

    kitty-everforest-themes.url = "github:ewal/kitty-everforest";
    kitty-everforest-themes.flake = false;

    kitty-gruvbox-themes.url = "github:wdomitrz/kitty-gruvbox-theme";
    kitty-gruvbox-themes.flake = false;

    attic.url = "github:zhaofengli/attic";
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
    secrets = import ./secrets.nix;

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

    defaultPackage = flake: system: flake.packages.${system}.default;

    defaultOverlays = [
      (final: prev: {
        deploy-rs-flake = defaultPackage deploy-rs final.system;
        indieweb-tools = defaultPackage inputs.indieweb-tools final.system;
        mqtt2influxdb2 = defaultPackage inputs.mqtt2influxdb2 final.system;
        felis = defaultPackage inputs.felis final.system;
        helixFlake = defaultPackage inputs.helix final.system;
      })
      weechatOverlay
      inputs.lamina.overlays.default
      inputs.attic.overlays.default
      inputs.mapthat-backend.overlays.default
    ];

    importNixpkgs = nixpkgs: system: overlays:
      import nixpkgs {
        inherit system overlays;
        config = {
          allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
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
      };

    defaultsFor = system: let
      unstable-overlay = final: prev: {
        unstable = importNixpkgs nixpkgs-unstable system defaultOverlays;
      };
      pkgs = importNixpkgs nixpkgs system ([unstable-overlay] ++ defaultOverlays);
    in {
      inherit pkgs system;
      specialArgs = {
        inherit pkgs localLib inputs secrets;
      };
    };

    defaultSystemModules =
      (localLib.modules.nixpkgs-pin.system nixpkgs nixpkgs-unstable)
      ++ [
        ./modules/system/base
        ./modules/system/static-sites
        ({config, ...}: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules =
            (localLib.modules.nixpkgs-pin.home-manager nixpkgs nixpkgs-unstable)
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
  in
    {
      darwinConfigurations = {
        "Sagittarius-A" = darwin.lib.darwinSystem (
          (defaultsFor flake-utils.lib.system.x86_64-darwin)
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
          (defaultsFor flake-utils.lib.system.x86_64-darwin)
          // {
            modules =
              defaultSystemModules
              ++ [
                home-manager.darwinModules.home-manager
                ./hosts/work/configuration.nix
              ];
          }
        );
      };

      nixosConfigurations = {
        # NixOS VM @ DO
        deneb = nixpkgs.lib.nixosSystem ((defaultsFor flake-utils.lib.system.x86_64-linux)
          // {
            modules =
              defaultSystemModules
              ++ [
                home-manager.nixosModules.home-manager
                ./hosts/deneb/configuration.nix
                inputs.mapthat-backend.nixosModules.default
              ];
          });

        # NixOS @ Hetzner
        kraz = nixpkgs.lib.nixosSystem ((defaultsFor flake-utils.lib.system.x86_64-linux)
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
        electra = nixpkgs.lib.nixosSystem ((defaultsFor flake-utils.lib.system.aarch64-linux)
          // {
            modules =
              defaultSystemModules
              ++ [
                home-manager.nixosModules.home-manager
                ./hosts/electra/configuration.nix
              ];
          });

        # Asus X550C laptop
        albeiro = nixpkgs.lib.nixosSystem ((defaultsFor flake-utils.lib.system.x86_64-linux)
          // {
            modules =
              defaultSystemModules
              ++ [
                home-manager.nixosModules.home-manager
                ./hosts/albeiro/configuration.nix
              ];
          });
      };

      deploy.nodes.electra = {
        sshUser = "vdx";
        sshOpts = ["-A"];
        hostname = "electra.lan";
        remoteBuild = true;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.electra;
      };

      deploy.nodes.deneb = {
        sshUser = "vdx";
        sshOpts = ["-A"];
        hostname = "deneb.vdx.hu";
        remoteBuild = true;
        fastConnection = false;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.deneb;
      };

      deploy.nodes.kraz = {
        sshUser = "vdx";
        sshOpts = ["-A" "-p5422"];
        hostname = "178.63.71.182";
        remoteBuild = true;
        fastConnection = false;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.kraz;
      };

      deploy.nodes.albeiro = {
        sshUser = "vdx";
        sshOpts = ["-A"];
        hostname = "albeiro.lan";
        remoteBuild = true;
        fastConnection = false;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.albeiro;
      };

      packages.${flake-utils.lib.system.x86_64-linux}.cache-warmup = let
        pkgs = (defaultsFor flake-utils.lib.system.x86_64-linux).specialArgs.pkgs;
      in
        pkgs.symlinkJoin {
          name = "cache-warmup";
          paths = [
            pkgs.attic-client
            pkgs.lamina
            # pkgs.indieweb-tools
          ];
        };

      packages.${flake-utils.lib.system.x86_64-darwin}.cache-warmup = let
        pkgs = (defaultsFor flake-utils.lib.system.x86_64-darwin).specialArgs.pkgs;
      in
        pkgs.symlinkJoin {
          name = "cache-warmup";
          paths = [
            pkgs.attic-client
            pkgs.helixFlake
            pkgs.lamina
            pkgs.felis
            pkgs.attic-client
          ];
        };
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = (defaultsFor system).specialArgs.pkgs;
      rebuild =
        if pkgs.stdenv.isDarwin
        then localLib.mkRebuildDarwin pkgs
        else localLib.mkRebuildNixos pkgs;
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.alejandra
          pkgs.deploy-rs-flake
          pkgs.git-crypt
          rebuild
        ];
      };
    }));
}
