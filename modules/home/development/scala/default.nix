{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.development.scala;

  # From: https://github.com/gvolpe/neovim-flake/blob/main/lib/metalsBuilder.nix
  metalsBuilder = {
    version,
    outputHash,
  }: let
    metalsDeps = pkgs.stdenv.mkDerivation {
      name = "metals-deps-${version}";
      buildCommand = ''
        export COURSIER_CACHE=$(pwd)
        ${pkgs.coursier}/bin/cs fetch org.scalameta:metals_2.13:${version} \
          -r bintray:scalacenter/releases \
          -r sonatype:snapshots > deps
        mkdir -p $out/share/java
        cp -n $(< deps) $out/share/java/
      '';
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      inherit outputHash;
    };
  in
    pkgs.metals.overrideAttrs (old: {
      inherit version;
      buildInputs = [metalsDeps];
    });

  metals = metalsBuilder {
    version = "1.3.0";
    outputHash = "sha256-otN4sqV2a0itLOoJ7x+VSMe0tl3y4WVovbA1HOpZVDw=";
  };

  metals-reload = pkgs.writeShellScriptBin "metals-reload" ''
    sbt=sbt
    if ! command -v $sbt &> /dev/null ; then
      sbt=${pkgs.sbt}/bin/sbt
    fi

    export SBT_OPTS="$SBT_OPTS -Dbloop.export-jar-classifiers=sources"
    # $sbt --client ";reload ;bloopInstall"
    $sbt bloopInstall
    ${pkgs.unstable.bloop}/bin/bloop clean
  '';
  # sbt-watcher = pkgs.writeShellScriptBin "sbt-watcher" ''
  #   export SBT_OPTS="$SBT_OPTS -Dbloop.export-jar-classifiers=sources"
  #   ${pkgs.fswatch}/bin/fswatch -o *.sbt project/*.sbt | xargs -n1 -I{} sh -c '\
  #     ${pkgs.sbt}/bin/sbt --client ";reload ;bloopInstall" && \
  #     ${pkgs.unstable.bloop}/bin/bloop clean'
  # '';
in {
  options.development.scala.enable = mkEnableOption "scala";

  config = mkIf cfg.enable {
    # programs.zsh.shellAliases = {
    #   sc = "sbt --client";
    #   sbi = "sbt --client bloopInstall";
    #   st = "sbt --client test";
    # };

    # Make navigation in dependency code work with metals/bloop
    programs.zsh.initExtra = ''
      export SBT_OPTS=-Dbloop.export-jar-classifiers=sources
    '';

    home.packages = [
      metals
      metals-reload
      # sbt-watcher
      pkgs.sbt
      pkgs.visualvm
      (pkgs.unstable.bloop.override {jre = config.development.java.jdk;})
    ];

    programs.zsh.shellAliases = {
      clean-metals = "rm -rf .bsp .metals .bloop project/metals.sbt project/.bloop";
      clean-metals-manual = "rm -rf .bsp .metals .bloop project/.bloop";
    };
  };
}
