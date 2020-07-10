{stdenv, pkgs, jdk, jre, coursier, ...}:

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
  version = "0.9.1+6-38226259-SNAPSHOT";
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
    outputHash     = "14kzqf51rvmqqs2y21114mjvbm4q8frc12mp5s8qd1pw7zjnr6an";
  };
in
stdenv.mkDerivation rec {
  name = "scala-metals";

  buildInputs = [ jdk pkgs.makeWrapper deps ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/metals-emacs \
      --prefix PATH : ${lib.makeBinPath [ jdk ]} \
      --add-flags "-cp $CLASSPATH" \
      --add-flags "${lib.concatStringsSep " " metalsJavaFlags}" \
      --add-flags "scala.meta.metals.Main"
  '';
}
