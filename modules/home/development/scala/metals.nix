{ stdenv, pkgs, jdk, coursier, ... }:

with pkgs;

let
  baseName = "metals";
  metalsJavaFlags = [
    "-XX:+UseG1GC"
    "-XX:+UseStringDeduplication"
    "-Xss4m"
    "-Xms100m"
    "-Dmetals.client=emacs"
    "-Dmetals.statistics=all"
    # "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005,quiet=y"
  ];
  version = "0.11.2";
  build = "1";
  deps = stdenv.mkDerivation {
    name = "${baseName}-deps-${version}";
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${coursier}/bin/cs fetch org.scalameta:metals_2.12:${version} \
        -r sonatype:snapshots \
        -r "bintray:scalacenter/releases" > deps
      mkdir -p $out/share/java
      cp -n $(< deps) $out/share/java/
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "b2b8a21e02acda10bc8a70465ae2ccf6a15f1a0b5c62a28787455958d9a0e755";
  };
in
stdenv.mkDerivation rec {
  name = "scala-metals-${version}+${build}";

  buildInputs = [ jdk pkgs.makeWrapper deps ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${jdk}/bin/java $out/bin/metals-emacs \
      --prefix PATH : ${lib.makeBinPath [ jdk ]} \
      --add-flags "-cp $CLASSPATH" \
      --add-flags "${lib.concatStringsSep " " metalsJavaFlags}" \
      --add-flags "scala.meta.metals.Main"
  '';
}