{
  mkSys = { system, nixpkgs, nixpkgs-unstable, overlays ? [ ] }:
    rec {
      inherit system;
      pkgs = import nixpkgs {
        inherit system overlays;
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system overlays;
      };
    };

  mkSystemHome =
    { sys
    , home-manager
    , nixpkgs
    , defaultModules
    }:

    configure:

    let
      mkHome =
        { username
        , configuration
        , nixConfigFlakeDir
        , jdk
        , hdpi ? true
        , homeDirectory ? if sys.system == "x86_64-darwin" then "/Users/${username}" else "/home/${username}"
        , extraModules ? [ ]
        }:
        let
          localPackages = import ../packages {
            inherit (sys) pkgs;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit (sys) system pkgs;
          inherit configuration username homeDirectory;
          extraModules = defaultModules ++ extraModules;
          extraSpecialArgs = {
            inherit nixpkgs jdk localPackages hdpi nixConfigFlakeDir;
          };
        };
    in
    mkHome (configure sys.pkgs);

}
