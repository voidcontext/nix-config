{ pkgs, ... }:

with pkgs;

let
  tfswitchVersion = "0.7.817";
in
stdenv.mkDerivation rec {
  name = "tfswitch";

  src = builtins.fetchurl {
    url = "https://github.com/warrensbox/terraform-switcher/releases/download/0.7.817/terraform-switcher_${tfswitchVersion}_darwin_amd64.tar.gz";
    sha256 = "191f6k5p1j72a05piyd7wpii437030dxa4fz09jhk0lm1z25bhzb";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    tar -zxvf $src
    cp terraform-switcher $out/bin/
    cp tfswitch $out/bin
  '';
}

