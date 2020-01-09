{ pkgs, ... }:

with import <nixpkgs> {};

let
  jre = pkgs.openjdk8_headless;
  metals = callPackage ./metals.nix { inherit jre; };
in
{
  home.packages = [
    jre
    pkgs.sbt
    pkgs.coursier

    metals

    pkgs.jekyll # for microsite generation
  ];
}
