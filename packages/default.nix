{ pkgs, ... }:

let
  adr-tools = import ./adr-tools.nix { inherit pkgs; };
  tfswitch = import ./tfswitch.nix { inherit pkgs; };
in
{
  inherit
    adr-tools
    tfswitch;
}
