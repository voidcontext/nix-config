{ pkgs, jdk, ... }:

{

  home.packages = [
    jdk
    pkgs.visualvm
    pkgs.leiningen
  ];
}
