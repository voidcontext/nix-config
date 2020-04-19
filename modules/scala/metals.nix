{stdenv, pkgs, jdk, jre, coursier, ...}:

with pkgs;

let
  baseName = "metals";
  metalsJavaFlags = ["-XX:+UseG1GC" "-XX:+UseStringDeduplication" "-Xss4m" "-Xms100m" "-Dmetals.client=emacs" ];
  version = "0.8.4+60-9d6f2e99-SNAPSHOT";
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
    outputHash     = "14k8m5d6dy828nslnk9bb7pk8d0y7p158ri6cwzjvs1c94cnc9zm";
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
