{config, pkgs, ...}:

let
  capabilities = rec {
    scala = true;
    haskell = false;
  };
in
{
   imports = [
      (import ../../home.nix { inherit config;  inherit pkgs; inherit capabilities; })
   ];
}
