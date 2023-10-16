{
  "description" = "voidcontext's dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/release-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:rycee/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";

    helix.url = "github:helix-editor/helix";

    indieweb-tools.url = "github:voidcontext/indieweb-tools";

    mqtt2influxdb2.url = "github:voidcontext/mqtt2influxdb2-rs";

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.05";

    lamina.url = "git+https://git.vdx.hu/voidcontext/lamina-rs.git";

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

    defaultPackage = flake: system: flake.packages.${system}.default;

    defaultOverlays = [
      (final: prev: {
        deploy-rs-flake = defaultPackage deploy-rs final.system;
        indieweb-tools = defaultPackage inputs.indieweb-tools final.system;
        mqtt2influxdb2 = defaultPackage inputs.mqtt2influxdb2 final.system;
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
            ];
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
              ./modules/home/development/nix
              ./modules/home/development/scala
              ./modules/home/programs/kitty
              ./modules/home/virtualization/lima
            ];
          home-manager.extraSpecialArgs = {
            inherit localLib localPackages inputs;
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

        # NixOS VM @ DO
        elnath = nixpkgs.lib.nixosSystem ((defaultsFor flake-utils.lib.system.x86_64-linux)
          // {
            modules =
              defaultSystemModules
              ++ [
                inputs.attic.nixosModules.atticd
                home-manager.nixosModules.home-manager
                ./hosts/elnath/configuration.nix
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
        fastConnection = true;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.deneb;
      };

      deploy.nodes.elnath = {
        sshUser = "root";
        sshOpts = ["-A" "-p5422"];
        hostname = "elnath.vdx.hu";
        remoteBuild = true;
        fastConnection = false;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.elnath;
      };

      deploy.nodes.albeiro = {
        sshUser = "vdx";
        sshOpts = ["-A"];
        hostname = "albeiro.lan";
        remoteBuild = true;
        fastConnection = true;

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.albeiro;
      };

      packages.${flake-utils.lib.system.x86_64-linux}.cache-warmup = 
        let pkgs = (defaultsFor flake-utils.lib.system.x86_64-linux).specialArgs.pkgs;
        in
          pkgs.symlinkJoin {
            name = "cache-warmup";
            paths = [
              pkgs.attic-client
              pkgs.lamina
              # pkgs.indieweb-tools
            ];
          };

      packages.${flake-utils.lib.system.x86_64-darwin}.cache-warmup = 
        let pkgs = (defaultsFor flake-utils.lib.system.x86_64-darwin).specialArgs.pkgs;
        in
          pkgs.symlinkJoin {
            name = "cache-warmup";
            paths = [
              pkgs.attic-client
              pkgs.helixFlake
              pkgs.lamina
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
