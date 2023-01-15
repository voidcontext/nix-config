{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:rycee/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";

    nil.url = "github:oxalica/nil";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    indieweb-tools.url = "github:voidcontext/indieweb-tools";
    # indieweb-tools.inputs.nixpkgs.follows = "nixpkgs";

    mqtt2influxdb2.url = "github:voidcontext/mqtt2influxdb2-rs";
    mqtt2influxdb2.inputs.nixpkgs.follows = "nixpkgs";

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/70a970f5a02b7febec1c3065e10c4155b99ecf86";
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
    lib = nixpkgs.lib;
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

    overlays = [
      (final: prev: {
        deploy-rs = deploy-rs.packages.${final.system}.default;
        indieweb-tools = inputs.indieweb-tools.packages.${final.system}.default;
        mqtt2influxdb2 = inputs.mqtt2influxdb2.packages.${final.system}.default;
        helixFlake = inputs.helix.packages.${final.system}.default;
      })
      weechatOverlay
      inputs.nil.overlays.default
    ];

    defaultsFor = system: let
      pkgs = import nixpkgs {
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
            ];
        };
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system overlays;
        config = {
          allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "steam"
              "steam-original"
              "steam-runtime"
              "nvidia-x11"
              "nvidia-settings"
            ];
        };
      };
    in {
      inherit pkgs system;
      specialArgs = {
        inherit pkgs pkgsUnstable localLib inputs secrets;
        localPackages = import ./packages {inherit pkgs;};
      };
    };

    defaultSystemModules =
      (localLib.modules.nixpkgs-pin.system nixpkgs nixpkgs-unstable)
      ++ [
        ./modules/system/base
        ./modules/system/static-sites
        ({
          config,
          pkgsUnstable,
          localPackages,
          ...
        }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules =
            (localLib.modules.nixpkgs-pin.home-manager nixpkgs nixpkgs-unstable)
            ++ [
              ./modules/home/base
              ./modules/home/development/java
              ./modules/home/development/scala
              ./modules/home/programs/kitty
              ./modules/home/virtualization/lima
            ];
          home-manager.extraSpecialArgs = {
            inherit localLib pkgsUnstable localPackages inputs;
            systemConfig = config;
          };
        })
      ];
  in
    {
      darwinConfigurations = lib.attrsets.genAttrs ["Sagittarius-A" "work"] (host:
        darwin.lib.darwinSystem (
          (defaultsFor flake-utils.lib.system.x86_64-darwin)
          // {
            modules =
              defaultSystemModules
              ++ [
                home-manager.darwinModules.home-manager
                (./hosts + "/${host}" + /configuration.nix)
              ];
          }
        ));

      nixosConfigurations = {
        # NixOS VM @ DO
        deneb = nixpkgs.lib.nixosSystem ((defaultsFor flake-utils.lib.system.x86_64-linux)
          // {
            modules =
              defaultSystemModules
              ++ [
                home-manager.nixosModules.home-manager
                ./hosts/deneb/configuration.nix
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
        hostname = "vdx.hu";
        remoteBuild = true;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.deneb;
      };

      deploy.nodes.albeiro = {
        sshUser = "vdx";
        sshOpts = ["-A"];
        hostname = "albeiro.lan";
        remoteBuild = true;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.albeiro;
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
          pkgs.deploy-rs
          pkgs.git-crypt
          rebuild
        ];
      };
    }));
}
