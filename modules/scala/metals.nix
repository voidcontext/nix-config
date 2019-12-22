{stdenv, pkgs, jdk, jre, coursier, ...}:

with import <nixpkgs> {};

let
  baseName = "metals";
  metalsJavaFlags = ["-XX:+UseG1GC" "-XX:+UseStringDeduplication" "-Xss4m" "-Xms100m" "-Dmetals.client=emacs" ];
  version = "0.7.6";
  deps = stdenv.mkDerivation {
    name = "${baseName}-deps-${version}";
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${coursier}/bin/coursier fetch org.scalameta:metals_2.12:${version} \
        -r sonatype:snapshots \
        -r "bintray:scalacenter/releases" > deps
      mkdir -p $out/share/java
      cp -n $(< deps) $out/share/java/
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    # outputHash     = "1rmgr5vhgmbgbgq58q3a2pnsjv6f118d3a4fa9y35izkd7djwnxa";
  };
in
stdenv.mkDerivation rec {
  name = "scala-metals";

  buildInputs = [ jdk makeWrapper deps ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/metals \
      --prefix PATH : ${lib.makeBinPath [ jdk ]} \
      --add-flags "-cp $CLASSPATH" \
      --add-flags "${lib.concatStringsSep " " metalsJavaFlags}" \
      --add-flags "scala.meta.metals.Main"
  '';
}
