{ pkgs, ... }:

let
  adrTools = pkgs.callPackage ./adr-tools.nix {};
in
{
  home.packages = [
    adrTools
  ];
}
