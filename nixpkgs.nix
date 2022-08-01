# To be used with nix-index (https://github.com/bennofs/nix-index/issues/172)
# $ nix-index -f nixpkgs.nix
{ system ? builtins.currentSystem
, config ? { }
, overlays ? [ ]
, ...
}@args:
import (import ./default.nix).inputs.nixpkgs args
