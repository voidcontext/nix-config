{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.development.scala;
  metals = pkgs.callPackage ./metals.nix { inherit (config.development.java) jdk; };

  sbt = pkgs.writeShellScriptBin "sbt" ''
    ${pkgs.sbt}/bin/sbt -java-home $JAVA_HOME "$@"
  '';
in
{
  options.development.scala.enable = mkEnableOption "scala";

  config = mkIf cfg.enable {

    home.file.".ammonite/predef.sc".text = ''
      interp.load.ivy(
        "com.lihaoyi" %
        s"ammonite-shell_''${scala.util.Properties.versionNumberString}" %
        ammonite.Constants.version
      )
      @
      val shellSession = ammonite.shell.ShellSession()
      import shellSession._
      import ammonite.ops._
      import ammonite.shell._
      ammonite.shell.Configure(interp, repl, wd)
    '';

    # emacs
    home.file.".emacs.d/init.el".text = (builtins.readFile ./init.el);

    programs.emacs.extraPackages = epkgs: with epkgs; [
      lsp-metals
      sbt-mode
      scala-mode
    ];

    home.packages = [
      pkgs.ammonite
      pkgs.asciinema
      pkgs.coursier
      sbt
      pkgs.visualvm
      pkgs.scalafmt
      pkgs.scalafix
      # pkgs.metals
      metals

      pkgs.jekyll # for microsite generation
      pkgs.hugo # for site generation (http4s)
    ];

    programs.zsh.shellAliases = {
      clean-metals = "rm -rf .bsp .metals .bloop project/metals.sbt project/.bloop";
    };
  };
}
