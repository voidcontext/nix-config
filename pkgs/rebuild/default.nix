{pkgs, ...}: let
  rebuildClj = pkgs.writeText "rebuild.clj" (builtins.readFile ./rebuild.clj);
  system =
    if pkgs.stdenv.isDarwin
    then "darwin"
    else "linux";
in
  pkgs.writeShellScriptBin "rebuild" ''
    ${pkgs.babashka}/bin/bb ${rebuildClj} --system ${system} "$@"
  ''
