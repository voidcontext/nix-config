{pkgs, ...}:

let
  sources = import ../../nix/sources.nix;
  all-hies = (import sources.all-hies {});
in
{
  home.packages = [
    pkgs.cabal-install
    pkgs.cabal2nix
    # Install stable HIE for GHC 8.6.5
    (all-hies.selection { selector = p: { inherit (p) ghc865; }; })
  ];
}
