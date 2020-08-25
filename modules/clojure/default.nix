{ pkgs, ... }:

let
  jre = pkgs.openjdk11-bootstrap;
in
{

  home.packages = [
    jre
    pkgs.visualvm
    pkgs.leiningen
  ];
}
