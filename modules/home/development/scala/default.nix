{ lib, pkgs, pkgsUnstable, config, ... }:

with lib;
let
  cfg = config.development.scala;
  sbt = pkgs.writeShellScriptBin "sbt" ''
    ${pkgs.sbt}/bin/sbt -java-home $JAVA_HOME "$@"
  '';
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
      sbt
      pkgs.visualvm
      pkgsUnstable.metals
    ];

    programs.zsh.shellAliases = {
      clean-metals = "rm -rf .bsp .metals .bloop project/metals.sbt project/.bloop";
      clean-metals-manual = "rm -rf .bsp .metals .bloop project/.bloop";
    };
  };
}
