{ stdenv, pkgs, ... }:

with pkgs;

stdenv.mkDerivation rec {
  name = "adr-tools";

  src = fetchFromGitHub {
    owner = "npryce";
    repo = "adr-tools";
    rev = "3.0.0";
    sha256 = "1igssl6853wagi5050157bbmr9j12703fqfm8cd7gscqwjghnk14";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r src/* $out/bin/
  '';
}

