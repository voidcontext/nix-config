{pkgs, pkgsUnstable, ...}: let
  adr-tools = import ./adr-tools.nix {inherit pkgs;};
  forgejo = import ./forgejo.nix {inherit pkgsUnstable;};
  marksman-bin = import ./marksman-bin.nix {inherit pkgs;};
  tfswitch = import ./tfswitch.nix {inherit pkgs;};
in {
  inherit
    adr-tools
    forgejo
    marksman-bin
    tfswitch
    ;
}
