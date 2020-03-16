{ pkgs, ... }:

let
  jre = pkgs.openjdk8_headless;
  metals = pkgs.callPackage ./metals.nix { inherit jre; };
in
{
  home.packages = [
    jre
    pkgs.sbt
    pkgs.coursier
    pkgs.asciinema

    metals

    pkgs.jekyll # for microsite generation
  ];
}
