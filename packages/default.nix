{ pkgs, ... }:

let
  adr-tools = import ./adr-tools.nix { inherit pkgs; };
  marksman-bin = import ./marksman-bin.nix { inherit pkgs; };
  tfswitch = import ./tfswitch.nix { inherit pkgs; };
in
{
  inherit
    adr-tools
    marksman-bin
    tfswitch;

}
