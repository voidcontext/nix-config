{ pkgs, jdk, ... }:

let
  metals = pkgs.callPackage ./metals.nix { inherit jdk;};
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

  home.file."bin/sbt" = {
    text = ''
    #!/usr/bin/env sh
    $HOME/.nix-profile/bin/sbt -java-home $JAVA_HOME $@
    '';
    executable = true;
  };

  home.packages = [
    jdk
    pkgs.ammonite
    pkgs.asciinema
    pkgs.coursier
    pkgs.sbt
    pkgs.visualvm
    # pkgs.metals
    metals

    pkgs.jekyll # for microsite generation
    pkgs.hugo # for site generation (http4s)
  ];
}
