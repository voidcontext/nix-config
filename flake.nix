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

    defaultsFor = system: defaultsForWithOverlays system [];

    defaultsForWithOverlays = system: overlays: let
      unstable-overlay = final: prev: {
        unstable = importNixpkgs nixpkgs-unstable system defaultOverlays;
      };
      pkgs = importNixpkgs nixpkgs system ([unstable-overlay] ++ defaultOverlays ++ overlays);
    in {
      inherit pkgs system;
      specialArgs = {
        inherit localLib inputs config-extras;
        inherit (inputs) nixpkgs nixos-hardware; # for nixos-uconsole
      };
    };

    defaultSystemModules =
      (localLib.modules.nixpkgs-pin.system nixpkgs nixpkgs-unstable)
      ++ [
        ./modules/system/base
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
    rec {
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
                ./modules/system/static-sites
                home-manager.nixosModules.home-manager
                ./hosts/deneb/configuration.nix
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

        orkaria = nixpkgs.lib.nixosSystem ((defaultsForWithOverlays flake-utils.lib.system.aarch64-linux [
            (final: super: {
              makeModulesClosure = x:
                super.makeModulesClosure (x // {allowMissing = true;});
            })
          ])
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

      deploy.nodes.orkaria = {
        sshUser = "vdx";
        sshOpts = ["-A"];
        hostname = "192.168.24.227";
        remoteBuild = false;
        fastConnection = false;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.orkaria;
      };

      packages.${flake-utils.lib.system.x86_64-linux}.cache-warmup = let
        pkgs = (defaultsFor flake-utils.lib.system.x86_64-linux).pkgs;
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
        pkgs = (defaultsFor flake-utils.lib.system.x86_64-darwin).pkgs;
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
      pkgs = (defaultsFor system).pkgs;
      rebuild =
        if pkgs.stdenv.isDarwin
        then localLib.mkRebuildDarwin pkgs
        else localLib.mkRebuildNixos pkgs;
      unlock-extras = pkgs.writeShellApplication {
        name = "unlock-extras";
        runtimeInputs = [pkgs.unstable.jujutsu];
        text = ''
          jj new
          jj desc -m "!DANGER! Exposed secrets!"
          cp -r ../nix-config-extras/default.nix extras/
          cp -r ../nix-config-extras/secrets.nix extras/
          cp -r ../nix-config-extras/hosts extras/
          touch .__DANGER__
          jj new
        '';
      };
      jj = pkgs.writeShellScriptBin "jj" ''
        if [ -f .__DANGER__ ] && [ "$1" == "git" ] && [ "$2" == "push" ]; then
          cat << EOF
        !!!DANGER!!!

        Secrets might be exposed!
        EOF
          exit 1
        fi

        ${pkgs.unstable.jujutsu}/bin/jj "$@"
      '';
      deploy = pkgs.writeShellScriptBin "deploy" ''
        if [ ! -f .__DANGER__ ]; then
          cat << EOF
        !!!DANGER!!!

        You probably want to run this command with unlocked extras.
        EOF
          exit 1
        fi

        ${pkgs.deploy-rs-flake}/bin/deploy
      '';
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.alejandra
          pkgs.git-crypt
          rebuild
          unlock-extras
          jj
          deploy
        ];
      };
    }));
}
