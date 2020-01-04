{pkgs, ...}:

let
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in
{
  home.packages = [
    pkgs.cabal-install
    pkgs.cabal2nix
    # Install stable HIE for GHC 8.6.5
    (all-hies.unstable.selection { selector = p: { inherit (p) ghc865; }; })
  ];
}
