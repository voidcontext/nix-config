{ pkgs, ... }:

let
  jre = pkgs.openjdk8_headless;
  metals = pkgs.callPackage ./metals.nix { inherit jre; };
in
{
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

  home.file.".itermocil/gen-itermocil.sc".source = ./gen-itermocil.sc;

  home.packages = [
    jre
    pkgs.sbt
    pkgs.coursier
    pkgs.asciinema
    pkgs.ammonite

    metals

    pkgs.jekyll # for microsite generation
    pkgs.hugo # for site generation (http4s)
  ];
}
