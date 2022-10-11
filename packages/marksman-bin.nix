{pkgs, ...}:

pkgs.stdenv.mkDerivation rec {
  pname = "marksman";
  version = "2022-09-13";

  src = pkgs.fetchurl {
    url = "https://github.com/artempyanykh/marksman/releases/download/${version}/marksman-macos";
    hash = "sha256-PlBCLe5NEv1eQWUtoypYQK18YOJE12+q/zFErGXWIP0=";
  };

  phases = ["installPhase" "patchPhase"];

  installPhase = ''
  mkdir -p $out/bin

  cp $src $out/bin/marksman && chmod +x $out/bin/marksman
  '';
}
