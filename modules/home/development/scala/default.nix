{ lib, pkgs, pkgsUnstable, config, ... }:

with lib;
let
  cfg = config.development.scala;
  sbt = pkgs.writeShellScriptBin "sbt" ''
    ${pkgs.sbt}/bin/sbt -java-home $JAVA_HOME "$@"
  '';
  
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
      extraJavaOpts = old.extraJavaOpts + " -Dmetals.client=nvim-lsp";
      buildInputs = [ metalsDeps ];
    });

  metals = metalsBuilder {
    # version = "0.11.7";
    # outputHash = "sha256-Zc/0kod3JM58WpyxwXiyQdixBHOJV7UDGg1YZtHJ3hw=";
    version = "0.11.8";
    outputHash = "sha256-j7je+ZBTIkRfOPpUWbwz4JR06KprMn8sZXONrtI/n8s=";
  };

in
{
  options.development.scala.enable = mkEnableOption "scala";

  config = mkIf cfg.enable {
    # emacs
    home.file.".emacs.d/init.el".text = (builtins.readFile ./init.el);
    
    programs.zsh.shellAliases = {
      sc  = "sbt --client";
      sbi = "sbt --client bloopInstall";
      st  = "sbt --client test";
    };
    
    programs.emacs.extraPackages = epkgs: with epkgs; [
      lsp-metals
      sbt-mode
      scala-mode
    ];

    home.packages = [
      metals
      sbt
      pkgs.visualvm
    ];

    programs.zsh.shellAliases = {
      clean-metals = "rm -rf .bsp .metals .bloop project/metals.sbt project/.bloop";
      clean-metals-manual = "rm -rf .bsp .metals .bloop project/.bloop";
    };
  };
}
