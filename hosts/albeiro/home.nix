{config, pkgs, ...}:

with builtins;

let
  capabilities = rec {
    scala = true;
    haskell = true;
  };

in
{
  imports = [
    (import ../../home.nix { inherit config;  inherit pkgs; inherit capabilities; })
    (import ../../modules/linux-desktop) {inherit config; inherit pkgs;}
  ];
}
