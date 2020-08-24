{ pkgs, ... }:

let
  jre = pkgs.jdk11_headless;
in
{

  home.packages = [
    jre
    pkgs.visualvm
    pkgs.leiningen
  ];
}
