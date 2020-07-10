{ pkgs, ... }:

let
  jre = pkgs.openjdk8_headless;
  jdk = jre;
  metals = pkgs.callPackage ./metals.nix { inherit jre; inherit jdk;};
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
    pkgs.ammonite
    pkgs.asciinema
    pkgs.coursier
    pkgs.sbt
    pkgs.visualvm

    metals

    pkgs.jekyll # for microsite generation
    pkgs.hugo # for site generation (http4s)
  ];
}
