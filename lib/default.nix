{
  mkSystemHome =
    { system
    , pkgs
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
        , homeDirectory ? if system == "x86_64-darwin" then "/Users/${username}" else "/home/${username}"
        , extraModules ? [ ]
        }:
        let
          localPackages = import ../packages {
            inherit pkgs;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs system configuration username homeDirectory;
          extraModules = defaultModules ++ extraModules;
          extraSpecialArgs = {
            inherit nixpkgs jdk localPackages hdpi nixConfigFlakeDir;
          };
        };
    in
    mkHome (configure pkgs);

}
