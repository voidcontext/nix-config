{ pkgs, ... }:

let
  itermocil = pkgs.callPackage ./itermocil.nix {
    pkgs = pkgs;
    buildPythonApplication = pkgs.python27Packages.buildPythonPackage;
  };
in
{
  home.packages = [
    pkgs.python27Packages.pyyaml
    itermocil
  ];
}
