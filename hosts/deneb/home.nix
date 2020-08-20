{config, pkgs, ...}:

let
  capabilities = rec {
    scala = false;
  };
in
{
  imports = [
    (import ../../home.nix { inherit config;  inherit pkgs; inherit capabilities; })
  ];
}
