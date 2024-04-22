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

    defaults = import ./defaults {inherit inputs localLib;};
  in
    {
      darwinConfigurations = import ./darwin.nix {
        inherit inputs localLib config-extras;
        inherit (defaults) defaultOverlays defaultConfig defaultSystemModules;
      };

      nixosConfigurations = import ./nixos.nix {
        inherit inputs localLib config-extras;
        inherit (defaults) defaultOverlays defaultConfig defaultSystemModules;
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

        ${pkgs.deploy-rs-flake}/bin/deploy "$@"
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
