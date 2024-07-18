{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.development.scala;

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
      pkgs.metals
      metals-reload
      # sbt-watcher
      pkgs.sbt
      pkgs.visualvm
      pkgs.scalafix
      (pkgs.unstable.bloop.override {jre = config.development.java.jdk;})
    ];

    programs.zsh.shellAliases = {
      clean-metals = "rm -rf .bsp .metals .bloop project/metals.sbt project/.bloop";
      clean-metals-manual = "rm -rf .bsp .metals .bloop project/.bloop";
    };
  };
}
