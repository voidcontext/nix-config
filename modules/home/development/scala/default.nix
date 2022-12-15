{ lib, pkgs, pkgsUnstable, config, ... }:

with lib;
let
  cfg = config.development.scala;

  # From: https://github.com/gvolpe/neovim-flake/blob/main/lib/metalsBuilder.nix
  metalsBuilder = { version, outputHash }:
    let
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
      buildInputs = [ metalsDeps ];
    });

  metals = metalsBuilder {
    version = "0.11.9";
    outputHash = "sha256-CJ34OZOAM0Le9U0KSe0nKINnxA3iUgqUMtS06YnjvVo=";
  };
  
  metals-reload = pkgs.writeShellScriptBin "metals-reload" ''
    export SBT_OPTS="$SBT_OPTS -Dbloop.export-jar-classifiers=sources"
    ${pkgs.sbt}/bin/sbt --client ";reload ;bloopInstall"
    ${pkgsUnstable.bloop}/bin/bloop clean
  '';
  
  sbt-watcher = pkgs.writeShellScriptBin "sbt-watcher" ''
    export SBT_OPTS="$SBT_OPTS -Dbloop.export-jar-classifiers=sources"
    ${pkgs.fswatch}/bin/fswatch -o *.sbt project/*.sbt | xargs -n1 -I{} sh -c '\
      ${pkgs.sbt}/bin/sbt --client ";reload ;bloopInstall" && \
      ${pkgsUnstable.bloop}/bin/bloop clean'
  '';
in
{
  options.development.scala.enable = mkEnableOption "scala";

  config = mkIf cfg.enable {
    
    programs.zsh.shellAliases = {
      sc  = "sbt --client";
      sbi = "sbt --client bloopInstall";
      st  = "sbt --client test";
    };

    # Make navigation in dependency code work with metals/bloop    
    programs.zsh.initExtra = ''
      export SBT_OPTS=-Dbloop.export-jar-classifiers=sources
    '';
    
    home.packages = [
      metals
      metals-reload
      sbt-watcher
      pkgs.sbt
      pkgs.visualvm
      pkgsUnstable.bloop
    ];

    programs.zsh.shellAliases = {
      clean-metals = "rm -rf .bsp .metals .bloop project/metals.sbt project/.bloop";
      clean-metals-manual = "rm -rf .bsp .metals .bloop project/.bloop";
    };
  };
}
