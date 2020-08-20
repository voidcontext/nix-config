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
  version = "0.9.2+121-053cebb0-SNAPSHOT";
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
    outputHash     = "0k21avvmcrxdfsn45gysm6gzmplqbqyp4qpj9a5f75q32d5kbnay";
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
